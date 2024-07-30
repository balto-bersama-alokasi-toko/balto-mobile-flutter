import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KelurahanDetailProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _kelurahanDetail = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get kelurahanDetail => _kelurahanDetail;

  Future<void> fetchKelurahanDetail(int kelurahanId) async {
    _isLoading = true;
    _kelurahanDetail = {}; // Clear previous data
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.baltohackathonbi2024.com/kelurahan-detail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kelurahan_id': kelurahanId}),
      );

      if (response.statusCode == 200) {
        _kelurahanDetail = json.decode(response.body);
      } else {
        _kelurahanDetail = {};
      }
    } catch (e) {
      _kelurahanDetail = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
