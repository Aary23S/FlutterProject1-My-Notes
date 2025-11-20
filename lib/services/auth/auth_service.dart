import 'package:registration_form/services/auth/auth_provider.dart';
import 'package:registration_form/services/auth/auth_user.dart';
import 'package:registration_form/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  // ---- STATIC INSTANCE ----
  static final AuthService _shared =
      AuthService(FirebaseAuthProvider());

  factory AuthService.firebase() => _shared;

  // ---- Forward all calls to provider ----

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) =>
      provider.register(email: email, password: password);

  @override
  Future<void> verifyEmail() => provider.verifyEmail();

  @override
  Future<void> initialize() => provider.initialize();
}
