///
/// to show other user's business profile
library;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String userId;

  BusinessProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bisnis'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'laporkan') {
                final Uri phoneNumber = Uri.parse('https://wa.me/6285746641537');
                launchUrl(phoneNumber);
              }
            },
              itemBuilder: (BuildContext context) {
                return {'Laporkan'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice.toLowerCase(),
                    child: Text(choice)
                  );
                }).toList();
              }
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['photoProfile'] != null && userData['photoProfile'].isNotEmpty
                      ? NetworkImage(userData['photoProfile'])
                      :  const AssetImage('assets/img/placeholderimg.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userData['name'] ?? 'No Name',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Bisnis',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('businesses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('Belum ada data bisnis');
                  }

                  var businesses = snapshot.data!.docs.map((doc) {
                    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      var business = businesses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: ListTile(
                              title: Text(business['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (business['imageUrl'] != null && business['imageUrl'].isNotEmpty)
                                    Image.network(business['imageUrl']),
                                  const SizedBox(height: 4),
                                  Text('${business['description']}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('${business['address']}')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.phone_enabled_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('${business['businessPhone']}')),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          final Uri phoneNumber = Uri.parse('https://wa.me/${business['businessPhone']}');
                                          launchUrl(phoneNumber);
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          padding: const EdgeInsets.symmetric(vertical: 16)
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.phone_outlined),
                                            SizedBox(width: 8),
                                            Text('Coba Hubungi'),
                                          ],
                                        )
                                    ),
                                  ),
                                  const SizedBox(height: 16)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
