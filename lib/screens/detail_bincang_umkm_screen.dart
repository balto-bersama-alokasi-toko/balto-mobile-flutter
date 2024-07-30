/// Screen to show post detail of Bincang UMKM
/// that contain comment if exist
library;

import 'dart:io';

import 'package:balto/providers/auth_provider.dart';
import 'package:balto/providers/komentar_bincang_umkm_provider.dart';
import 'package:balto/screens/post_bincang_umkm_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/list_tile_comment_bincang_umkm.dart';
import '../providers/bincang_umkm_provider.dart';
import '../utils/timestamp_formatter.dart';
import 'business_profile_screen.dart';

class DetailBincangUmkmScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> post;

  const DetailBincangUmkmScreen({
    super.key,
    required this.postId,
    required this.post
  });

  @override
  State<DetailBincangUmkmScreen> createState() => _DetailBincangUmkmScreenState();
}

class _DetailBincangUmkmScreenState extends State<DetailBincangUmkmScreen> {

  final TextEditingController _commentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isDeletingComment = false;
  bool isDeletingPost = false;


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
        _image = File(pickedFile.path);
      });
    }
  }

  // since _pickImage not handle permission of gallery. This one will handle the gallery picker image
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              )
            ],
          );
        }
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _sendComment() async {
    if(_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong'))
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final commentProvider = Provider.of<CommentBincangUMKMProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String? commentImageUrl;

    if (_image != null) {
      commentImageUrl = await commentProvider.uploadImage(_image!);
    }

    DocumentSnapshot userProfileSnapshot = await authProvider.getUserProfile(currentUser!.uid);
    var userProfile = userProfileSnapshot.data() as Map<String, dynamic>;

    String commentId = await commentProvider.addComment(
      postId: widget.postId,
      commentImage: commentImageUrl,
      commentText: _commentController.text,
      commentUserId: currentUser.uid,
      commentUsername: userProfile['name'] ?? 'Anonymous',
      commentUserprofileImage: userProfile['photoProfile'] ?? '',
    );

    _commentController.clear();
    _removeImage();

    setState(() {
      isLoading = false;
      widget.post['postcomment'].add(commentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Komentar berhasil dikirim')),
    );

  }

  @override
  Widget build(BuildContext context) {

    final currentUser = Provider.of<AuthProvider>(context).user;
    final isPostOwner = currentUser?.uid == widget.post['postuserid'];

    void showMoreOptions(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPostOwner)
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Kiriman'),
                    onTap: () {
                      // To Do : Handle Edit post
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostBincangUmkmScreen(
                                postId: widget.postId,
                              )));
                    },
                  ),
                if (isPostOwner)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Hapus Kiriman'),
                    onTap: () async {
                      setState(() {
                        isDeletingPost = true;
                      });

                      final bincangUmkmProvier = Provider.of<BincangUmkmProvider>(context, listen: false);

                      try {
                        await bincangUmkmProvier.deletePost(widget.postId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kiriman berhasil dihapus')),
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghapus kiriman: $e')),
                        );
                      } finally {
                        setState(() {
                          isDeletingPost = false;
                        });
                      }
                    },
                  ),
                if (!isPostOwner)
                  ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text('Laporkan Kiriman'),
                    onTap: () {
                      final Uri phoneNumber = Uri.parse('https://wa.me/6285746641537');
                      launchUrl(phoneNumber);
                      Navigator.pop(context);
                    },
                  )
              ],
            );
          });
    }

    void showCommentOptions(BuildContext context, bool isCommentOwner, String commentId) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCommentOwner)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Hapus Komentar'),
                  onTap: () async {

                    setState(() {
                      isDeletingComment = true;
                    });

                    // Aksi untuk mengedit komentar
                    final commentProvider = Provider.of<CommentBincangUMKMProvider>(context, listen: false);

                    try {
                      await commentProvider.deleteComment(commentId, widget.postId);
                      setState(() {
                        widget.post['postcomment'].remove(commentId);
                        isDeletingComment = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Komentar berhasil dihapus')),
                      );
                    } catch (e) {
                      setState(() {
                        isDeletingComment = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus komentar: $e')),
                      );
                    }

                    Navigator.pop(context);
                  },
                ),
              if (!isCommentOwner)
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Laporkan Komentar'),
                  onTap: () {

                    final Uri phoneNumber = Uri.parse('https://wa.me/6285746641537');
                    launchUrl(phoneNumber);
                    Navigator.pop(context);
                  },
                ),
            ],
          );
        },
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kiriman'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Text('Post ID: $postId', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (currentUser != null && currentUser.uid != widget.post['postuserid']) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusinessProfileScreen(userId: widget.post['postuserid']),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: widget.post['postuserprofileimage'] != ''
                                      ? NetworkImage(widget.post['postuserprofileimage'])
                                      : const AssetImage('assets/img/placeholderimg.png')
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.post['postusername']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  TimestampFormatter(firestoreTimestamp: widget.post['posttime'])
                                ],
                              )
                            ),
                            IconButton(
                                onPressed: () => showMoreOptions(context),
                                icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.post['postimage'] != null && widget.post['postimage'] != '')
                          Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12))),
                            clipBehavior: Clip.hardEdge,
                            child: FadeInImage.assetNetwork(
                                placeholder: 'assets/img/placeholderimg.png',
                                image: widget.post['postimage']),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          widget.post['posttext'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_rounded,
                              size: 16,
                              color: Color(0xff94a3b8),
                            ),
                            SizedBox(width: 8),
                            Text('Komentar'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final commentId = widget.post['postcomment'][index];
                            return StreamBuilder<DocumentSnapshot>(
                                stream: Provider.of<CommentBincangUMKMProvider>(context, listen: false).getCommentStream(commentId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    return const Text('No Data');
                                  }
                                  var commentData = snapshot.data!.data() as Map<String, dynamic>;
                                  bool isCommentOwner = currentUser?.uid == commentData['commentUserId'];
                                  return ListTileCommentBincangUmkm(
                                      leadingContent: GestureDetector(
                                        onTap: () {
                                          if (currentUser != null && currentUser.uid != commentData['commentUserId']) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BusinessProfileScreen(userId: commentData['commentUserId']),
                                              ),
                                            );
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: commentData['commentUserprofileImage'] != null && commentData['commentUserprofileImage'].isNotEmpty
                                            ? FadeInImage.assetNetwork(
                                                placeholder: 'assets/img/placeholderimg.png',
                                                image: commentData['commentUserprofileImage'],
                                                height: 28,
                                                width: 28,
                                                fit: BoxFit.cover,
                                                imageErrorBuilder: (context, error, stackTrace) {
                                                  return Text(
                                                    error.toString(),
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.error,
                                                    ),
                                                  );
                                                },
                                          )
                                            : const CircleAvatar(
                                              radius: 14,
                                              backgroundImage:
                                              AssetImage('assets/img/placeholderimg.png',
                                            ),
                                          )
                                        ),
                                      ),
                                      titleContent: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  commentData['commentUsername'],
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                  ),
                                                ),
                                                TimestampFormatter(
                                                    firestoreTimestamp:
                                                    commentData['commentTime'])
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () => showCommentOptions(
                                                  context, isCommentOwner, commentId),
                                              icon: const Icon(Icons.more_vert))
                                        ],
                                      ),
                                      subtitleContent: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (commentData['commentImage'] != null &&
                                              commentData['commentImage'] != '')
                                            Card(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(8)),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                'assets/img/placeholderimg.png',
                                                image: commentData['commentImage'],
                                              ),
                                            ),
                                          Text(commentData['commentText']),
                                        ],
                                      ),
                                  );
                                }
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(thickness: 0.2),
                          itemCount: widget.post['postcomment'] != null
                              ? widget.post['postcomment'].length
                              : 0,
                        )
                      ],
                    )
                  ),
                )
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2,2)
                    )
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Visibility(
                        visible: _image == null,
                        child: IconButton(
                          onPressed: () => showImagePickerOptions(context),
                          icon: const Icon(
                            Icons.attachment_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      if(_image !=null)
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => {
                                      _removeImage()
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 20,
                                    ),
                                  )
                                )
                              ],
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                                hintText: "Tambahkan komentar...",
                                hintStyle: const TextStyle(
                                  color: Color(0xff94a3b8)
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6)
                                ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1)
                              )
                            ),
                          )
                      ),
                      IconButton(
                          onPressed: () {
                            _sendComment();
                          },
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.blue,
                          )
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          if(isLoading || isDeletingComment || isDeletingPost)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
