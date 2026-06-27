import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// State ketika login sukses tapi memiliki > 1 role, wajib pilih role dulu
class AuthNeedsRoleSelection extends AuthState {
  final UserModel user;

  const AuthNeedsRoleSelection({required this.user});

  @override
  List<Object?> get props => [user];
}

// State ketika berhasil login/masuk dengan peran aktif tunggal yang sah
class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String activeRole;

  const AuthAuthenticated({required this.user, required this.activeRole});

  @override
  List<Object?> get props => [user, activeRole];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// State saat pendaftaran berhasil dilakukan
class AuthRegisterSuccess extends AuthState {
  final String message;

  const AuthRegisterSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {}