import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/error_dialog.dart';
import '../components/password_text_input.dart';
import '../providers/auth_provider.dart' as ap;



class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showErrorDialog(context, 'New password and confirm password do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<ap.AuthProvider>(context, listen: false);
      final user = authProvider.user!;

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(_newPasswordController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password Berhasil Diubah'))
      );
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
        title: const Text('Change Password'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PasswordTextInput(
              textEditingControllerHere: _oldPasswordController,
              labelTextHere: 'Password Lama',
            ),
            const SizedBox(height: 12),
            PasswordTextInput(
              textEditingControllerHere: _newPasswordController,
              labelTextHere: 'Password Baru',
            ),
            const SizedBox(height: 12),
            PasswordTextInput(
              textEditingControllerHere: _confirmPasswordController,
              labelTextHere: 'Konfirmasi Password Baru',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                  )
                ),
                child: const Text('Ubah Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
