// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart' show User;


//creating a middleman so the repetition of the FirebaseAuth will reduce
class AuthUser 
{
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email,required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user)=> AuthUser(email: user.email,isEmailVerified: user.emailVerified);

}
