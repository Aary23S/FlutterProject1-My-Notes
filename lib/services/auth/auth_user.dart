// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart' show User;


//creating a middleman so the repetition of the FirebaseAuth will reduce
class AuthUser 
{
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user)=> AuthUser(user.emailVerified);

}
