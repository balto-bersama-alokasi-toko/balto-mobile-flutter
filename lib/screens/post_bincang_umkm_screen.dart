/// Screen to create post or edit post
/// in Bincang UMKM Feature
library;

import 'dart:io';
import 'package:balto/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../components/error_dialog.dart';
import '../providers/bincang_umkm_provider.dart';

class PostBincangUmkmScreen extends StatefulWidget {
  final String? postId;

  const PostBincangUmkmScreen({super.key, this.postId});

  @override
  State<PostBincangUmkmScreen> createState() => _PostBincangUmkmScreenState();
}

class _PostBincangUmkmScreenState extends State<PostBincangUmkmScreen> {
  // dialog confirmation leaving the page
  Future<bool?> _showBackDialogConfirmation() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Anda yakin?'),
            content:
                const Text("Apakah Anda yakin akan meninggalkan halaman ini?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Tetap di Halaman Ini')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Keluar Halaman'))
            ],
          );
        });
  }

  final _formKey = GlobalKey<FormState>();
  String _postText = '';
  File? _postImage;
  String? _initialImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  User? _currentUser;
  String? _userName;
  String? _userProfileImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser().then((_) {
      if (widget.postId != null) {
        _loadPostData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadPostData() async {
    final provider = Provider.of<BincangUmkmProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot postSnapshot = await provider.getPostById(widget.postId!);
      if (postSnapshot.exists) {
        setState(() {
          _postText = postSnapshot['posttext'];
          _initialImage = postSnapshot['postimage'];
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _loadCurrentUser() async {
    final provider = Provider.of<BincangUmkmProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    _currentUser = provider.getCurrentUser();
    if (_currentUser != null) {
      try {
        DocumentSnapshot userSnapshot = await provider.getUserProfile(_currentUser!.uid);
        if (userSnapshot.exists) {
          _userName = userSnapshot['name'];
          _userProfileImage = userSnapshot['photoProfile'];
        }
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }



  // as per 17 July 2024 can't see permission on gallery. This will use on camera only
  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus permissionStatus;

    // Check permissions
    if (source == ImageSource.camera) {
      permissionStatus = await Permission.camera.request();
    } else {
      permissionStatus = await Permission.photos.request();
      if (permissionStatus != PermissionStatus.granted) {
        permissionStatus = await Permission.photos.request();
      }
    }

    if (permissionStatus != PermissionStatus.granted) {
      if (permissionStatus.isPermanentlyDenied) {
        openAppSettings();
      } else {
        // Show snackbar if permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission is required to take pictures.'
                  : 'Photo library permission is required to select pictures.',
            ),
          ),
        );
      }
      return;
    }

    // Pick image
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        // _image = pickedFile;
        // _postImage = File(pickedFile.path);
        _postImage = File(pickedFile.path);
        _initialImage = null; // Reset initial image if a new image is picked
      });
    }
  }

  // since _pickImage not handle permission of gallery. This one will handle the gallery picker image
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // _postImage = File(pickedFile.path);
        _postImage = File(pickedFile.path);
        _initialImage = null;
      });
    } else {
      // Show snackbar if no image is picked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BincangUmkmProvider>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialogConfirmation() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
                (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.postId == null ? 'Buat Kiriman Bincang UMKM' : 'Edit Kiriman Bincang UMKM'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _postText,
                              minLines: 3,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                hintText: 'Apa yang Anda Pikirkan',
                                hintStyle: TextStyle(color: Color(0xff94a3b8)),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 1),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _postText = value!;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_postImage != null) Image.file(_postImage!),
                            if (_initialImage != null && _postImage == null) Image.network(_initialImage!),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  label: const Text('Kamera'),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: const Text('Galeri'),
                                  onPressed: _pickImageFromGallery,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          setState(() {
                            _isSubmitting = true;
                          });

                          String? imageUrl;
                          if (_currentUser == null) {
                            showErrorDialog(context, "User not logged in");
                            setState(() {
                              _isSubmitting = false;
                            });
                            return;
                          }

                          if (_postImage != null) {
                            imageUrl = await provider.uploadImage(_currentUser!.uid, _postImage!.path);
                          } else {
                            imageUrl = _initialImage; // Pertahankan gambar yang ada jika tidak ada gambar baru yang dipilih
                          }

                          if (widget.postId == null) {
                            // Create new post
                            await provider.createPost(_postText, _currentUser!.uid, _userName!, _userProfileImage!, postImage: imageUrl);
                          } else {
                            // Update existing post
                            await provider.updatePost(widget.postId!, _postText, postImage: imageUrl);
                          }

                          setState(() {
                            _isSubmitting = false;
                          });

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MyHomePage()),
                                (Route<dynamic> route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(widget.postId == null ? 'Buat Kiriman' : 'Update Kiriman'),
                    ),
                  ),
                ),
              ],
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
