import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/error_dialog.dart';
import '../providers/auth_provider.dart';


class EditProfileScreen extends StatefulWidget {


  const EditProfileScreen({
    super.key,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _image;
  String? _currentPhotoUrl;
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user!;
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        if (data['photoProfile'] != null && data['photoProfile'].isNotEmpty) {
          setState(() {
            _currentPhotoUrl = data['photoProfile'];
          });
        }
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String userId) async {
    if (_image == null) return;

    final storageRef = FirebaseStorage.instance.ref().child('user_profile_images').child('$userId.jpg');
    await storageRef.putFile(_image!);
    final imageUrl = await storageRef.getDownloadURL();

    // updating in 'users' collection
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'photoProfile': imageUrl,
    });

    // updating in 'bincang-umkm-post' collection
    final postDocs = await FirebaseFirestore.instance
        .collection('bincang-umkm-post')
        .where('postuserid', isEqualTo: userId)
        .get();
    for (var doc in postDocs.docs) {
      await doc.reference.update({
        'postuserprofileimage': imageUrl,
      });
    }

    // updating in 'bincang-umkm-comment' collection
    final commentDocs = await FirebaseFirestore.instance
        .collection('bincang-umkm-comment')
        .where('commentUserId', isEqualTo: userId)
        .get();
    for (var doc in commentDocs.docs) {
      await doc.reference.update({
        'commentUserprofileImage': imageUrl,
      });
    }

  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user!;
      final newName = _nameController.text;

      if (newName.isNotEmpty) {
        // Update name in the 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
        });

        // Update name in 'bincang-umkm-post' collection
        final postDocs = await FirebaseFirestore.instance
            .collection('bincang-umkm-post')
            .where('postuserid', isEqualTo: user.uid)
            .get();
        for (var doc in postDocs.docs) {
          await doc.reference.update({
            'postusername': newName,
          });
        }

        // Update name in 'bincang-umkm-comment' collection
        final commentDocs = await FirebaseFirestore.instance
            .collection('bincang-umkm-comment')
            .where('commentUserId', isEqualTo: user.uid)
            .get();
        for (var doc in commentDocs.docs) {
          await doc.reference.update({
            'commentUsername': newName,
          });
        }
      }



      await _uploadImage(user.uid);
      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _currentPhotoUrl != null
                          ? NetworkImage(_currentPhotoUrl!)
                          : const AssetImage('assets/img/placeholderimg.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    const Text('Current Photo'),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : const AssetImage('assets/img/placeholderimg.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    const Text('New Photo'),
                  ],
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Change Photo'),
              onPressed: _pickImage,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
