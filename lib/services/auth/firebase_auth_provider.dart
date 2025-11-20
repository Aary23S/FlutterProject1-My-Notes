// ignore_for_file: unused_import, unused_catch_clause

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:registration_form/firebase_options.dart';
import 'package:registration_form/services/auth/auth_exceptions.dart';
import 'package:registration_form/services/auth/auth_provider.dart';
import 'package:registration_form/services/auth/auth_user.dart';


class FirebaseAuthProvider implements AuthProvider
{
 //In firebase_auth_provider.dart the currtUser getter reads the current 
 //Firebase User via FirebaseAuth.instance.currentUser. That Firebase call 
 //returns either a User object or null if nobody is signed in. 
 //The getter checks that result and, when non-null, calls AuthUser.fromFirebase(user) 
 //to build and return an AuthUser instance; otherwise it returns null

@override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLogInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else {
        throw GenericException();
      }
    } catch (_) {
      throw GenericException();
    }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLogInException();
    }
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLogInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyUsedException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else {
        throw GenericException();
      }
    } catch (_) {
      throw GenericException();
    }
  }

  @override
  Future<void> verifyEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLogInException();
    }
  }

  @override
  Future<void> initialize() async {
    // Already initialized in main.dart — NO NEED to do it again.
    return;
  }
}