import 'package:balto/auth_wrapper.dart';
import 'package:balto/firebase_options.dart';
import 'package:balto/providers/auth_provider.dart';
import 'package:balto/providers/bincang_umkm_provider.dart';
import 'package:balto/providers/business_profile_preview_provider.dart';
import 'package:balto/providers/kelurahan_detail_provider.dart';
import 'package:balto/providers/komentar_bincang_umkm_provider.dart';
import 'package:balto/providers/location_around_provider.dart';
import 'package:balto/providers/location_prediction_provider.dart';
import 'package:balto/providers/merchant_category_provider.dart';
import 'package:balto/providers/merchant_detail_provider.dart';
import 'package:balto/screens/akun_screen.dart';
import 'package:balto/screens/beranda_screen.dart';
import 'package:balto/screens/bincang_umkm_screen.dart';
import 'package:balto/screens/business_preview_screeen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BincangUmkmProvider()),
        ChangeNotifierProvider(create: (_) => CommentBincangUMKMProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => LocationAroundProvider()),
        ChangeNotifierProvider(create: (_) => LocationPredictionProvider()),
        ChangeNotifierProvider(create: (_) => KelurahanDetailProvider()),
        ChangeNotifierProvider(create: (_) => MerchantDetailProvider()),
        ChangeNotifierProvider(create: (_) => MerchantCategoryProvider())
      ],
      child: MaterialApp(
        title: 'Balto',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
           colorScheme: ColorScheme.fromSeed(
             seedColor: Colors.blue,
             brightness: Brightness.dark,
           ),
          useMaterial3: true
          // brightness: Brightness.dark
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget> [
    BerandaScreen(),
    AuthWrapper(child: BincangUmkmScreen()),
    AuthWrapper(child: BusinessPreviewScreen()),
    AuthWrapper(child: AkunScreen())
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: 'Bincang UMKM'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Profil Bisnis'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun'
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
