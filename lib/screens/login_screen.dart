import 'package:balto/components/password_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../components/error_dialog.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Navigator.pop(context); // Pop the login screen if the user is already logged in
      }
    });
  }


  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .signInWithEmail(_emailController.text, _passwordController.text);
      Navigator.pop(context);
    } catch (e) {
      showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
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
        title: const Text('Login'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Lottie.asset(
                        'assets/loti/Animation - 1720170871928.json',
                        height: 260,
                        fit: BoxFit.fill
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1)
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PasswordTextInput(
                        textEditingControllerHere: _passwordController,
                        labelTextHere: "Password"
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Development Progress')
                              )
                          );
                        },
                        child: const Text(
                          'Lupa password ?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'atau'
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/img/googlelogologin.png',
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Login dengan Google'),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            'Belum punya akun ? '
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    SvgPicture.asset(
                      'assets/img/balorenewtextlogo.svg',
                      height: 40,
                    ),
                  ],
                )
            ),
          ),
    );
  }
}
