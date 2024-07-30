import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }


  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? businessName,
    String? address,
    String? businessDescription,
    double? monthlyIncome,
    String? businessPhone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // user data in collection 'user'
        String defaultName = email.split('@')[0];
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'name': defaultName,
          'photoProfile': '',
          'isPremium': false,
        });

        // add business collection
        if (businessName != null || address != null || businessDescription != null || monthlyIncome != null || businessPhone != null) {
          await _firestore.collection('users').doc(user.uid).collection(
              'businesses').add({
            if (businessName != null) 'name': businessName,
            if (address != null) 'address': address,
            if (businessDescription != null) 'description': businessDescription,
            if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
            if (businessPhone != null) 'businessPhone': businessPhone,
            'createdAt': Timestamp.now(),
          });
        }

      }

    } catch (e) {
      print(e); // Print any errors that occur during registration
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'id': user.uid,
            'email': user.email,
            'name': user.displayName ?? user.email!.split('@')[0],
            'photoProfile': user.photoURL ?? '',
            'isPremium': false,
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }




}
