import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationPredictionProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _locations = [];

  bool get isLoading => _isLoading;
  List<dynamic> get locations => _locations;

  Future<void> fetchPredictionLocations(Map<String, String> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.mocki.io/v2/ise0kv73/location-prediction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _locations = result['location_predictions'];
      } else {
        _locations = [];
      }
    } catch (e) {
      _locations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
