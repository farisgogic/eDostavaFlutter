import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/global_variables.dart';

class OmiljeniProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  OmiljeniProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future addJeloToOmiljeniList(int kupacId, int jeloId, int restoranId) async {
    final requestBody = {
      'KupacId': kupacId,
      'JeloId': jeloId,
      'RestoranId': restoranId,
    };
    final token = await _getToken();
    final response = await http!.post(
      Uri.parse('${Constants.baseUrl}/Omiljeni'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to add jelo to omiljeni list.');
    }
  }

  Future<List<dynamic>> get(dynamic searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Omiljeni");

    if (searchObject != null) {
      final kupacId = searchObject['KupacId'];

      if (kupacId != null) {
        url = url.replace(queryParameters: {
          'KupacId': kupacId.toString(),
        });
      }
    }

    var response = await http!.get(url);
    if (response.statusCode < 400) {
      final responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception("Greska");
    }
  }

  Future<bool> removeJeloFromOmiljeniList(
      int kupacId, int jeloId, int restoranId) async {
    final token = await _getToken();
    final response = await http!.delete(
      Uri.parse(
          '${Constants.baseUrl}/Omiljeni/RemoveJeloFromOmiljeniList/$kupacId/$jeloId/$restoranId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      notifyListeners();
      return true;
    } else {
      throw Exception('Failed to remove jelo from omiljeni list.');
    }
  }
}
