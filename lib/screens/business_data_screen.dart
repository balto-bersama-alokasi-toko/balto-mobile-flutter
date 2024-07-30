///
/// Screen for user add their business data
///
library;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/business_profile_preview_provider.dart';

class BusinessDataScreen extends StatefulWidget {
  @override
  _BusinessDataScreenState createState() => _BusinessDataScreenState();
}

class _BusinessDataScreenState extends State<BusinessDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addBusiness() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToFirebase(_image!);
      }

      // Parsing monthly income from formatted text
      double monthlyIncomeFormated = double.parse(_monthlyIncomeController.text.replaceAll('.', ''));
      // if ( _monthlyIncomeController.text.isNotEmpty) {
      //   monthlyIncomeFormated = double.parse(_monthlyIncomeController.text.replaceAll('.', ''));
      // }

      // Parsing business phone number with prefix +62
      String businessPhoneFormatted = '62${_phoneController.text}';
      // if (_phoneController.text.isNotEmpty) {
      //   businessPhoneFormatted = '62' + _phoneController.text;
      // }

      // Add business to Firestore
      Provider.of<BusinessProvider>(context, listen: false).addBusiness(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        monthlyIncome: monthlyIncomeFormated,
        phone: businessPhoneFormatted,
        imageUrl: imageUrl,
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('business_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Business'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Usaha',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1)
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nama usaha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                                labelText: 'Deskripsi Usaha',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 1)
                                )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan deskripsi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                                labelText: 'Alamat',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 1)
                                )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan alamat';
                              }
                              return null;
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
                                    borderSide: BorderSide(color: Colors.blue, width: 1)
                                )
                            ),
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
                              if (value == null || value.isEmpty) {
                                return 'Masukkan pendapatan bulanan';
                              }
                              if (value.isNotEmpty && double.tryParse(value.replaceAll('.', '')) == null) {
                                return 'Masukkan jumlah yang benar';
                              }
                              // if (double.tryParse(value) == null) {
                              //   return 'Masukkan jumlah yang benar';
                              // }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                                labelText: 'Nomor Telepon Bisnis',
                                prefixText: '+62 ',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 1)
                                )
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nomor telepon yang valid';
                              }
                              if (value != null && value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                                return 'Masukkan nomor telepon yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _image != null
                              ? Image.file(_image!)
                              : TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Tambah Gambar Bisnis'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  )
                )
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addBusiness,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                    child: const Text('Tambah Data Bisnis'),
                  ),
                ),
              )
            ],
          ),
          if(_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      )
    );
  }
}
