import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/error_dialog.dart';
import '../providers/auth_provider.dart' as ap;
import 'login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<ap.AuthProvider>(context, listen: false);
      final user = authProvider.user!;
      final userId = user.uid;

      // Re-authenticate the user
      if (user.providerData.any((info) => info.providerId == 'password')) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: await _getUserPassword(context),
          ),
        );
      } else if (user.providerData.any((info) => info.providerId == 'google.com')) {
        // Re-authenticate with Google
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          );
          await user.reauthenticateWithCredential(credential);
        } else {
          throw FirebaseAuthException(
            code: 'ERROR_REAUTHENTICATE_FAILED',
            message: 'Re-authenticate with Google failed',
          );
        }
      }

      // Reference to the user's subcollection
      CollectionReference businessesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('businesses');

      // Get all documents in the subcollection
      QuerySnapshot businessesSnapshot = await businessesRef.get();

      // Start a batch
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add deletion of each document in the subcollection to the batch
      for (QueryDocumentSnapshot doc in businessesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Get all documents in bincang-umkm-comment where commentUserId is userId
      QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('bincang-umkm-comment')
          .where('commentUserId', isEqualTo: userId)
          .get();

      // Process each comment to delete and update the corresponding post's postcomment array
      for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
        // Add deletion of the comment document to the batch
        batch.delete(commentDoc.reference);

        // Get the post ID associated with the comment
        String postId = commentDoc['postId'];

        // Update the post's postcomment array to remove the comment ID
        DocumentReference postRef = FirebaseFirestore.instance.collection('bincang-umkm-post').doc(postId);
        batch.update(postRef, {
          'postcomment': FieldValue.arrayRemove([commentDoc.id])
        });
      }

      // Get all documents in bincang-umkm-post where postuserid is userId
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('bincang-umkm-post')
          .where('postuserid', isEqualTo: userId)
          .get();

      // Add deletion of each document in bincang-umkm-post to the batch
      for (QueryDocumentSnapshot doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Delete user account
      await user.delete();

      // Sign out the user
      await authProvider.signOut();

      // Show success message and navigate to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getUserPassword(BuildContext context) async {
    final passwordController = TextEditingController();
    final completer = Completer<String>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              completer.complete(passwordController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Akun'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/deletionaccount.png',
              width: 200,
            ),
            const Text(
              'Peringatan: Penghapusan akun akan menghapus semua data Anda. Aksi ini tidak dapat dikembalikan di waktu kedepannya',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
