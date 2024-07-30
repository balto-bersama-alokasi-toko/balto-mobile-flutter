
import 'package:balto/components/list_tile_post_bincang_umkm.dart';
import 'package:balto/screens/detail_bincang_umkm_screen.dart';
import 'package:balto/screens/post_bincang_umkm_screen.dart';
import 'package:balto/utils/timestamp_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../providers/bincang_umkm_provider.dart';
import 'business_profile_screen.dart';

class BincangUmkmScreen extends StatefulWidget {
  const BincangUmkmScreen({super.key});

  @override
  _BincangUmkmScreenState createState() => _BincangUmkmScreenState();
}

class _BincangUmkmScreenState extends State<BincangUmkmScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bincangUmkmProvider = Provider.of<BincangUmkmProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser; // Get the current user

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBarWithGradient(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bincangUmkmProvider.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          final posts = snapshot.data!.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          return ListView.separated(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final commentCount =
                  post['postcomment'] != null ? post['postcomment'].length : 0;
              return ListTilePostBincangUmkm(
                leadingContent: GestureDetector(
                  onTap: () {
                    if (currentUser != null && currentUser.uid != post['postuserid']) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessProfileScreen(userId: post['postuserid']),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: post['postuserprofileimage'] != null &&
                              post['postuserprofileimage'].isNotEmpty
                          ? FadeInImage.assetNetwork(
                              width: 48,
                              height: 48,
                              placeholder: 'assets/img/placeholderimg.png',
                              image: post['postuserprofileimage'],
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
                              radius: 24,
                              backgroundImage:
                                  AssetImage('assets/img/placeholderimg.png'),
                            )),
                ),
                titleContent: Row(
                  children: [
                    Text(
                      post['postusername'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TimestampFormatter(firestoreTimestamp: post['posttime'])
                  ],
                ),
                subtitleContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post['postimage'] != null && post['postimage'] != '')
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/img/placeholderimg.png',
                          image: post['postimage'],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      post['posttext'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_rounded,
                          size: 16,
                          color: Color(0xff94a3b8),
                        ),
                        const SizedBox(width: 8),
                        Text('$commentCount komentar'),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailBincangUmkmScreen(
                          postId: post['id'], post: post),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 0.4,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PostBincangUmkmScreen()));
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AppBarWithGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Set the status bar color to transparent
      statusBarIconBrightness:
          Brightness.light, // Set the status bar icon brightness
    );

    // Apply the system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3EC6FF), Color(0xff1A71FD)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/img/baltologwhite.svg',
                height: 24,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Center(
                  child: Text(
                    'Bincang UMKM',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'BalooThambi',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 56), // Spacer to balance the row
            ],
          ),
        ),
      ),
    );
  }
}
