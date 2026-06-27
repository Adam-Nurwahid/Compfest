import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Event saat pengguna menekan tombol login
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// Event saat pengguna memilih peran aktif (untuk akun multi-role)
class RoleSelected extends AuthEvent {
  final String targetRole;

  const RoleSelected({required this.targetRole});

  @override
  List<Object?> get props => [targetRole];
}

// Event saat pengguna mensubmit form registrasi
class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String selectedRole;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.selectedRole,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber, selectedRole];
}


// Event untuk keluar dari aplikasi
class LogoutRequested extends AuthEvent {}