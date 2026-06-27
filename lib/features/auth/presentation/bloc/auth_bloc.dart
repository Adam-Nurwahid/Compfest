import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:compfest/data/dummy/dummy_data.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RoleSelected>(_onRoleSelected);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 1. Autentikasi via Supabase Auth
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user == null) {
        if (!_fallbackToLocalLogin(event, emit)) {
          emit(const AuthError(message: 'Gagal mendapatkan data pengguna.'));
        }
        return;
      }

      // 2. Ambil data profil publik
      UserModel userModel;
      try {
        final profileData = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        userModel = UserModel.fromJson(profileData);
      } catch (e) {
        // Fallback to user_metadata injected during registration
        final email = response.user!.email ?? 'user';
        final username = email.split('@')[0];
        final metaRole = response.user!.userMetadata?['selected_role'] as String?;
        final fallbackRole = metaRole ?? 'buyer';
        userModel = UserModel(
          id: response.user!.id,
          username: username,
          ownedRoles: [fallbackRole],
          activeRole: fallbackRole,
        );
      }

      // Pastikan activeRole tidak kosong
      String activeRole = userModel.activeRole.isNotEmpty
          ? userModel.activeRole.toLowerCase()
          : (userModel.ownedRoles.isNotEmpty ? userModel.ownedRoles.first.toLowerCase() : 'buyer');

      if (userModel.activeRole.isEmpty && userModel.ownedRoles.isNotEmpty) {
        try {
          await _supabaseClient
              .from('profiles')
              .update({'active_role': activeRole})
              .eq('id', userModel.id);
        } catch (_) {}
      }

      // 3. Jalankan aturan bisnis multi-role SEAPEDIA
      if (userModel.ownedRoles.length > 1) {
        // Perbaikan: Gunakan .copyWith untuk memperbarui activeRole secara aman
        emit(AuthNeedsRoleSelection(user: userModel.copyWith(activeRole: activeRole)));
      } else {
        // Perbaikan: Gunakan .copyWith untuk memperbarui activeRole secara aman
        emit(AuthAuthenticated(user: userModel.copyWith(activeRole: activeRole), activeRole: activeRole));
      }
    } on AuthException catch (e) {
      if (!_fallbackToLocalLogin(event, emit)) {
        emit(AuthError(message: e.message));
      }
    } catch (e) {
      if (!_fallbackToLocalLogin(event, emit)) {
        emit(AuthError(message: 'Terjadi kesalahan sistem: ${e.toString()}'));
      }
    }
  }

  bool _fallbackToLocalLogin(LoginSubmitted event, Emitter<AuthState> emit) {
    final emailNormalized = event.email.toLowerCase().trim();
    final localUserIndex = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == emailNormalized || u.username.toLowerCase() == emailNormalized,
    );

    if (localUserIndex != -1 && dummyUsers[localUserIndex].password == event.password) {
      final localUser = dummyUsers[localUserIndex];

      // Perbaikan: Amankan nilai activeRole agar tidak mengirim string kosong ("")
      final String safeActiveRole = localUser.activeRole.isNotEmpty
          ? localUser.activeRole.toLowerCase()
          : (localUser.roles.isNotEmpty ? localUser.roles.first.toLowerCase() : 'buyer');

      final userModel = UserModel(
        id: localUser.id,
        username: localUser.username,
        ownedRoles: localUser.roles.map((r) => r.toLowerCase()).toList(),
        activeRole: safeActiveRole,
      );

      if (userModel.ownedRoles.length > 1) {
        emit(AuthNeedsRoleSelection(user: userModel));
      } else {
        emit(AuthAuthenticated(user: userModel, activeRole: safeActiveRole));
      }
      return true;
    }
    return false;
  }

  Future<void> _onRoleSelected(RoleSelected event, Emitter<AuthState> emit) async {
    if (state is AuthNeedsRoleSelection || state is AuthAuthenticated) {
      final currentUser = (state is AuthNeedsRoleSelection)
          ? (state as AuthNeedsRoleSelection).user
          : (state as AuthAuthenticated).user;

      emit(AuthLoading());
      try {
        // Hanya update ke Supabase jika ID bertipe UUID valid (bukan akun dummy lokal)
        if (!currentUser.id.startsWith('user_')) {
          try {
            await _supabaseClient
                .from('profiles')
                .update({'active_role': event.targetRole})
                .eq('id', currentUser.id);
          } catch (_) {}
        }

        final updatedUser = UserModel(
          id: currentUser.id,
          username: currentUser.username,
          ownedRoles: currentUser.ownedRoles,
          activeRole: event.targetRole,
        );

        emit(AuthAuthenticated(user: updatedUser, activeRole: event.targetRole));
      } catch (e) {
        emit(AuthError(message: 'Gagal memperbarui peran sesi: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Gagal logout: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {
          'full_name': event.fullName,
          'phone_number': event.phoneNumber,
          'selected_role': event.selectedRole.toLowerCase(),
        },
      );

      if (response.user == null) {
        return emit(const AuthError(message: 'Gagal mendaftar pengguna.'));
      }

      final username = event.email.split('@')[0];
      try {
        await _supabaseClient.from('profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'owned_roles': [event.selectedRole.toLowerCase()],
          'active_role': event.selectedRole.toLowerCase(),
        });
      } catch (e) {
        // Profile table may not exist; role is preserved in user_metadata
      }

      emit(const AuthRegisterSuccess(
        message: 'Akun berhasil dibuat! Silakan masuk menggunakan kredensial baru Anda.',
      ));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Gagal membuat akun: ${e.toString()}'));
    }
  }
}