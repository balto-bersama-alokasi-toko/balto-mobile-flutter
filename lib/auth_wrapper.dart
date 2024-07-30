import 'package:balto/providers/auth_provider.dart';
import 'package:balto/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  AuthWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user == null) {
      return SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Lottie.asset(
                    'assets/loti/Animation - 1720166665157.json',
                    width: 400,
                    height: 400,
                    fit: BoxFit.fill
                ),
                SvgPicture.asset(
                  'assets/img/balorenewtextlogo.svg',
                  height: 80,
                ),
                const SizedBox(height: 40),
                const Text('Anda harus Login terlebih dahulu'),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16)
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Login'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    } else {
      return child;
    }
  }
}