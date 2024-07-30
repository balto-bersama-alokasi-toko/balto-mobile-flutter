import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationAroundProvider with ChangeNotifier {
  bool isLoading = false;
  List<dynamic> kelurahans = [];

  Future<void> fetchLocations(String publicPlace) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://api.baltohackathonbi2024.com/location-around');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'public_place': publicPlace}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      kelurahans = responseData['kelurahans'];
    } else {
      kelurahans = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
