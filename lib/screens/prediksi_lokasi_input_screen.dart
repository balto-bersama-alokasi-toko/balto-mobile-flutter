import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class PrediksiLokasiInputScreen extends StatefulWidget {
  const PrediksiLokasiInputScreen({super.key});

  @override
  State<PrediksiLokasiInputScreen> createState() => _PrediksiLokasiInputScreenState();
}

class _PrediksiLokasiInputScreenState extends State<PrediksiLokasiInputScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Prediksi Lokasi Page'),
    );
  }
}


class AppBarWithGradient extends StatelessWidget {
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
