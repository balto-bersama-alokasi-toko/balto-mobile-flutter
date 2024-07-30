import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getBusinesses() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('businesses')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID to the map
            return data;
          }).toList());
    }
    return Stream.value([]);
  }

  Future<void> addBusiness({
    required String name,
    required String description,
    required String address,
    required double monthlyIncome,
    required String phone,
    String? imageUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('businesses')
          .add({
        'name': name,
        'description': description,
        'address': address,
        'monthlyIncome': monthlyIncome,
        'businessPhone': phone,
        'imageUrl': imageUrl,
      });
      notifyListeners();
    }
  }


  Future<void> updateBusiness({
    required String businessId,
    required String name,
    required String description,
    required String address,
    required double monthlyIncome,
    required String phone,
    String? imageUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('businesses')
          .doc(businessId)
          .update({
        'name': name,
        'description': description,
        'address': address,
        'monthlyIncome': monthlyIncome,
        'businessPhone': phone,
        'imageUrl': imageUrl,
      });
      notifyListeners();
    }
  }

  Future<void> deleteBusiness(String businessId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('businesses')
          .doc(businessId)
          .delete();
      notifyListeners();
    }
  }


}
