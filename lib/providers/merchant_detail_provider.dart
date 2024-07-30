import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantDetailProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _merchantDetail = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get merchantDetail => _merchantDetail;

  Future<void> fetchMerchantDetail(int merchantId) async {
    _isLoading = true;
    _merchantDetail = {}; // Clear previous data
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.baltohackathonbi2024.com/merchant-detail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'merchant_id': merchantId}),
      );

      if (response.statusCode == 200) {
        _merchantDetail = json.decode(response.body);
      } else {
        _merchantDetail = {};
      }
    } catch (e) {
      _merchantDetail = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
