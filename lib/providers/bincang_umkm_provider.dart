// bincang_umkm_provider.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BincangUmkmProvider with ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('bincang-umkm-post')
        .orderBy('posttime', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getPostById(String postId) async {
    return await _firestore.collection('bincang-umkm-post').doc(postId).get();
  }

  Future<void> createPost(
      String postText,
      String userId,
      String userName,
      String userProfileImage,
      {String? postImage}
  ) async {
    try {
      await _firestore.collection('bincang-umkm-post').add({
        'posttext': postText,
        'posttime': Timestamp.now(),
        'postuserid': userId,
        'postusername': userName,
        'postuserprofileimage': userProfileImage,
        'postimage': postImage,
        'postcomment': [],
        'postvideo':""
      });
    } catch (e) {
      print('Error crete post : $e');
    }
  }


  Future<void> updatePost(String postId, String postText, {String? postImage}) async {
    final postRef = FirebaseFirestore.instance.collection('bincang-umkm-post').doc(postId);

    // get data post if the current image is exist
    final postSnapshot = await postRef.get();
    String? existingImage = postSnapshot.data()?['postimage'];

    // if image was null, keep current image
    postImage = postImage ?? existingImage;

    await postRef.update({
      'posttext': postText,
      'postimage': postImage,
    });
  }

  Future<String> uploadImage(String userId, String imagePath) async {
    try {
      final ref = _storage.ref().child('bincang_umkm_images').child(userId).child(DateTime.now().toIso8601String());
      final uploadTask = ref.putFile(File(imagePath));
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return '';
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }


  Future<void> deletePost(String postId) async {
    try {
      // Get the post document
      final postDoc = await _firestore.collection('bincang-umkm-post').doc(postId).get();

      if (postDoc.exists) {
        // Get the list of comment IDs
        List<dynamic> commentIds = postDoc.data()?['postcomment'] ?? [];

        // Delete each comment document in bincang-umkm-comment collection
        for (String commentId in commentIds) {
          await _firestore.collection('bincang-umkm-comment').doc(commentId).delete();
        }

        // Delete the post document
        await _firestore.collection('bincang-umkm-post').doc(postId).delete();
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

}
