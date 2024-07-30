import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/business_profile_preview_provider.dart';


class EditBusinessScreen extends StatefulWidget {
  final Map<String, dynamic> business;

  EditBusinessScreen({required this.business});

  @override
  _EditBusinessScreenState createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _monthlyIncomeController;
  late TextEditingController _phoneController;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business['name']);
    _descriptionController = TextEditingController(text: widget.business['description']);
    _addressController = TextEditingController(text: widget.business['address']);
    _monthlyIncomeController = TextEditingController(text: widget.business['monthlyIncome'].toString());
    _phoneController = TextEditingController(text: widget.business['businessPhone']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        widget.business['imageUrl'] = null; // Set imageUrl to null to remove old image
      });
    }
  }

  Future<void> _updateBusiness() async {

    setState(() {
      _isLoading = true;
    });

    String? imageUrl = widget.business['imageUrl'];
    if (_image != null) {
      imageUrl = await _uploadImageToFirebase(_image!);
    }

    double monthlyIncomeFormated = double.parse(_monthlyIncomeController.text.replaceAll('.', ''));
    String businessPhoneFormatted = '62${_phoneController.text}';

    if (_formKey.currentState!.validate()) {
      Provider.of<BusinessProvider>(context, listen: false).updateBusiness(
        businessId: widget.business['id'],
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
        title: const Text('Edit Bisnis'),
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Text(widget.business.toString()),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                  labelText: 'Nama usaha',
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
                                  ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the monthly income';
                                }
                                // if (double.tryParse(value) == null) {
                                //   return 'Please enter a valid number';
                                // }
                                if (value.isNotEmpty && double.tryParse(value.replaceAll('.', '')) == null) {
                                  return 'Masukkan jumlah yang benar';
                                }
                                return null;
                              },
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
                                  return 'Please enter the phone number';
                                }
                                if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                                  return 'Masukkan nomor telepon yang valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            if (widget.business['imageUrl'] != null && widget.business['imageUrl'].isNotEmpty)
                              Image.network(widget.business['imageUrl']),
                            if (_image != null)
                              Image.file(_image!),
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text('Change Image'),
                            ),
                            // const SizedBox(
                            //   height: 36,
                            // ),
                            // ElevatedButton(
                            //   onPressed: _updateBusiness,
                            //   child: const Text('Update Business'),
                            // ),
                          ],
                        ),
                      )
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateBusiness,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ), child: const Text('Update Data Bisnis'),
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
