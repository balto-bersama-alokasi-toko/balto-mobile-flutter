import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class CommentBincangUMKMProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<DocumentSnapshot> getCommentStream(String commentId) {
    return _firestore.collection('bincang-umkm-comment').doc(commentId).snapshots();
  }

  Future<String> addComment({
    required String postId,
    String? commentImage,
    required String commentText,
    required String commentUserId,
    required String commentUsername,
    required String commentUserprofileImage,
  }) async {
    final commentData = {
      'commentImage': commentImage,
      'commentText': commentText,
      'commentTime': Timestamp.now(),
      'commentUserId': commentUserId,
      'commentUsername': commentUsername,
      'commentUserprofileImage': commentUserprofileImage,
      'postId': postId,
      'commentVideo':""
    };
    
    DocumentReference commentRef = await _firestore.collection('bincang-umkm-comment').add(commentData);
    
    // update post document with comment Id
    await _firestore.collection('bincang-umkm-post').doc(postId).update({
      'postcomment': FieldValue.arrayUnion([commentRef.id])
    });

    return commentRef.id;
  }
  
  Future<String?> uploadImage(File image) async {
    try {
      final ref = _storage.ref().child('bincang_umkm_images').child('comment').child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      // Menghapus komentar dari koleksi bincang-umkm-comment
      await _firestore.collection('bincang-umkm-comment').doc(commentId).delete();

      // Menghapus ID komentar dari array 'postcomment' pada dokumen post
      await _firestore.collection('bincang-umkm-post').doc(postId).update({
        'postcomment': FieldValue.arrayRemove([commentId])
      });
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

}