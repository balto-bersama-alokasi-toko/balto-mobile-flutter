import 'package:balto/screens/business_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/business_profile_preview_provider.dart';
import 'edit_business_preview_item_screen.dart';

class BusinessPreviewScreen extends StatefulWidget {
  const BusinessPreviewScreen({super.key});

  @override
  State<BusinessPreviewScreen> createState() => _BusinessPreviewScreenState();
}

class _BusinessPreviewScreenState extends State<BusinessPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBarBusinessPreviewWithGradient(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: Provider.of<BusinessProvider>(context).getBusinesses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading businesses'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/shopicon.png',
                        width: 200,
                      ),
                      const Text('Belum ada data bisnis.'),
                ],
              ));
            } else {
              List<Map<String, dynamic>> businesses = snapshot.data!;
              return ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> business = businesses[index];
                  String formattedIncome = NumberFormat.decimalPattern('id').format(business['monthlyIncome']);
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xff94a3b8)),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Theme(
                        data: ThemeData().copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: Colors.black54,
                          textColor: Colors.black54,
                          title: Row(
                            children: [
                              const Icon(
                                Icons.storefront_outlined,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Text(business['name'] ?? 'No Name'),
                            ],
                          ),
                          children: [
                            ListTile(
                              title: const Text(
                                  'Deskripsi',
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                              subtitle: Text(
                                business['description'] ?? 'No Description',
                                style: const TextStyle(
                                  fontSize: 16
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                  'Alamat',
                                style: TextStyle(
                                  fontSize: 12
                                ),
                              ),
                              subtitle: Text(
                                business['address'] ?? 'No Address',
                                style: const TextStyle(
                                  fontSize: 16
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                'Pendapatan per Bulan',
                                style: TextStyle(
                                    fontSize: 12
                                ),
                              ),
                              subtitle: Text(
                                'Rp ${formattedIncome}',
                                style: const TextStyle(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                'Kontak Bisnis',
                                style: TextStyle(
                                    fontSize: 12
                                ),
                              ),
                              subtitle: Text(
                                business['businessPhone'] ?? 'No Phone',
                                style: const TextStyle(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            if (business['imageUrl'] != null && business['imageUrl'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/img/placeholderimg.png',
                                    image: business['imageUrl'],
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Navigate to the edit screen with the business data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditBusinessScreen(business: business),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Show confirmation dialog before deleting
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this business?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Provider.of<BusinessProvider>(context, listen: false)
                                                    .deleteBusiness(business['id']);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => BusinessDataScreen())
          );
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Tambah Data Bisnis',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AppBarBusinessPreviewWithGradient extends StatelessWidget {
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
                    'Profil Bisnis',
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
