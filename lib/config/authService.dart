import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Stream<User?> get user {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    return FirebaseAuth.instance.userChanges();
  }
}