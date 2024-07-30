import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantCategoryProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _merchants = [];

  bool get isLoading => _isLoading;
  List<dynamic> get merchants => _merchants;

  Future<void> fetchMerchantsByCategory(String category) async {
    _isLoading = true;
    _merchants = []; // Clear previous data
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.baltohackathonbi2024.com/merchant-category'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'merchant_category': category}),
      );

      if (response.statusCode == 200) {
        _merchants = json.decode(response.body)['merchants'];
      } else {
        _merchants = [];
      }
    } catch (e) {
      _merchants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
