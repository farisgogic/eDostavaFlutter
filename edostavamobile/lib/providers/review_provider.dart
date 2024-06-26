import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Review.dart';
import '../constants/global_variables.dart';

class ReviewProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  ReviewProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<Review> insertReview(Review review) async {
    try {
      final token = await _getToken();
      final response = await http!.post(
        Uri.parse('${Constants.baseUrl}/Recenzija'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(review.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        notifyListeners();

        return Review.fromJson(responseData);
      } else {
        throw Exception('Greska prilikom unosenja ocjene');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Review>> getReviews(Map<String, dynamic> searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Recenzija");

    if (searchObject.isNotEmpty) {
      url = Uri.parse(
          "${Constants.baseUrl}/Recenzija?kupacId=${searchObject['kupacId']}&restoranId=${searchObject['restoranId']}");
    }

    var response = await http!.get(url);

    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<Review> list =
          data.map((x) => Review.fromJson(x)).cast<Review>().toList();

      return list;
    } else {
      throw Exception("Greska prilikom dohvatanja recenzija");
    }
  }

  Future<Review> updateReview(int id, Review update) async {
    try {
      final token = await _getToken();
      final response = await http!.put(
        Uri.parse('${Constants.baseUrl}/Recenzija/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(update.toJson()),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        notifyListeners();

        return Review.fromJson(responseData);
      } else {
        throw Exception('Error updating review');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
