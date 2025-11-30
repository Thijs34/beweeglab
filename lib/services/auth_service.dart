import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/services/user_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService.instance;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _userService.ensureUserDocument(
          uid: uid,
          email: credential.user?.email ?? email,
        );
      }
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error));
    } catch (_) {
      throw const AuthException('Failed to sign in. Please try again.');
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _userService.ensureUserDocument(
          uid: uid,
          role: 'observer',
          email: credential.user?.email ?? email,
          displayName: displayName,
        );
      }
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error));
    } catch (_) {
      throw const AuthException('Failed to create account. Please try again.');
    }
  }

  Future<String> getUserRole(String uid) {
    return _userService.fetchUserRole(uid);
  }

  String _mapAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'email-already-in-use':
        return 'An account already exists with that email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      default:
        return 'Something went wrong (${exception.code}). Please try again.';
    }
  }
}
