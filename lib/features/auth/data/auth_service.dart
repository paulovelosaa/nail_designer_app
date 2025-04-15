import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // CADASTRO
  Future<User?> register(
    String email,
    String password, {
    required String name,
    required String phone,
    required String instagram,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'id': result.user!.uid,
          'nome': name,
          'telefone': phone,
          'instagram': instagram,
          'email': email,
          'tipo': 'cliente', // ajuste conforme necessidade
        });
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // RESET SENHA
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
