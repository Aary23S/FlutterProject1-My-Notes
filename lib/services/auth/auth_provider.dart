// ignore_for_file: unused_import

import 'package:registration_form/services/auth/auth_user.dart';


//abstract class is just the blue print of the functions which has to be executed.
//only the method name is declared in the abstarct class 
//abstract class do not create the object

abstract class AuthProvider 
{
  
  Future<void>initialize();
  AuthUser? get currentUser;

  Future<AuthUser>login({
    required String email,
    required String password,
  });

  Future<AuthUser>register({
    required String email,
    required String password,
  });

  Future<void>logout();
  Future<void>verifyEmail();
}