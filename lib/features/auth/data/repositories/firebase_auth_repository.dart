import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

/// Implementation of [AuthRepository] backed by [FirebaseAuthService].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuthService? service})
      : _service = service ?? FirebaseAuthService();

  final FirebaseAuthService _service;

  @override
  Stream<AuthUser?> get authStateChanges => _service.authStateChanges;

  @override
  AuthUser? get currentUser => _service.currentUser;

  @override
  Future<AuthUser> signInWithGoogle() => _service.signInWithGoogle();

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _service.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<AuthUser> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _service.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: fullName,
      );

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _service.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() => _service.sendEmailVerification();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _service.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<void> signOut() => _service.signOut();
}
