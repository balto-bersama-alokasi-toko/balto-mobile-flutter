import 'package:balto/screens/delete_account_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/auth_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  Future<DocumentSnapshot> _fetchUserData(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    int retries = 7;
    while (!userDoc.exists && retries > 0) {
      await Future.delayed(const Duration(seconds: 1));
      userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      retries--;
    }
    return userDoc;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You need to login first'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: _fetchUserData(authProvider.user!.uid),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('An error occurred or user data not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text('User data is null'));
          }

          return Scaffold(
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: AppBarAkunWithGradient(),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userData['photoProfile'] != ''
                        ? NetworkImage(userData['photoProfile'])
                        : const AssetImage('assets/img/placeholderimg.png') as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text('${userData['name']}'),
                  const SizedBox(height: 0),
                  Text('${authProvider.user!.email}'),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_location_rounded),
                    title: const Text('Riwayat Pencarian Lokasi Ideal'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Ubah Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordScreen())
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Hapus Akun',
                      style: TextStyle(
                          color: Colors.red
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DeleteAccountScreen())
                      );
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                    },
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Sign Out'),
                        SizedBox(width: 12),
                        Icon(Icons.power_settings_new_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16)
                ],
              ),
            ),
          );
        },
      );
    }
  }
}



class AppBarAkunWithGradient extends StatelessWidget {
  const AppBarAkunWithGradient({super.key});

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Set the status bar color to transparent
      statusBarIconBrightness: Brightness.light, // Set the status bar icon brightness
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
                    'Akun',
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
