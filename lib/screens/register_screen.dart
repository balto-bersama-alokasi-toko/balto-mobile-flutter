import 'package:balto/components/password_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../components/error_dialog.dart';
import '../providers/auth_provider.dart' as ap;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  bool _isLoading = false;
  bool _includeBusinessData = false;



  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });



      try {
        // Parsing monthly income from formatted text
        double? monthlyIncomeFormated;
        if (_includeBusinessData && _monthlyIncomeController.text.isNotEmpty) {
          monthlyIncomeFormated = double.parse(_monthlyIncomeController.text.replaceAll('.', ''));
        }

        // Parsing business phone number with prefix +62
        String? businessPhoneFormatted;
        if (_includeBusinessData && _businessPhoneController.text.isNotEmpty) {
          businessPhoneFormatted = '62' + _businessPhoneController.text;
        }

        await Provider.of<ap.AuthProvider>(context, listen: false).registerWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          businessName: _includeBusinessData ? _businessNameController.text : null,
          address: _includeBusinessData ? _addressController.text : null,
          businessDescription: _includeBusinessData ? _businessDescriptionController.text : null,
          monthlyIncome: monthlyIncomeFormated,
          businessPhone: businessPhoneFormatted,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Lottie.asset(
                  'assets/loti/Animation - 1720413579841.json',
                  height: 220,
                  fit: BoxFit.fill),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.blue, width: 1))),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Email Anda';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan alamat email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PasswordTextInput(
                textEditingControllerHere: _passwordController,
                labelTextHere: "Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan password Anda';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _includeBusinessData,
                    onChanged: (bool? value) {
                      setState(() {
                        _includeBusinessData = value ?? false;
                      });
                    },
                  ),
                  const Text('Masukkan data bisnis'),
                ],
              ),
              if (_includeBusinessData) ...[
                const SizedBox(height: 24),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                      labelText: 'Nama Usaha',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1))),
                  validator: (value) {
                    return null; // No validation required as this field is optional
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1))),
                  validator: (value) {
                    return null; // No validation required as this field is optional
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _businessDescriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi Usaha',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1))),
                  validator: (value) {
                    return null; // No validation required as this field is optional
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _monthlyIncomeController,
                  decoration: const InputDecoration(
                      labelText: 'Pendapatan Bulanan',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1))),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      return;
                    }
                    String newValue = value.replaceAll('.', '');
                    if (int.tryParse(newValue) != null) {
                      setState(() {
                        _monthlyIncomeController.text = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(newValue));
                        _monthlyIncomeController.selection = TextSelection.fromPosition(TextPosition(offset: _monthlyIncomeController.text.length));
                      });
                    }
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty && double.tryParse(value.replaceAll('.', '')) == null) {
                      return 'Masukkan jumlah yang benar';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _businessPhoneController,
                  decoration: const InputDecoration(
                      labelText: 'Nomor Telepon Bisnis',
                      prefixText: '+62 ',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1))),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Masukkan nomor telepon yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/img/balorenewtextlogo.svg',
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
