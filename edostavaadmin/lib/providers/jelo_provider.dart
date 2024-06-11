import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/global_variables.dart';
import '../models/jelo.dart';

class JeloProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  JeloProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<Jelo> getById(int id) async {
    final response =
        await http!.get(Uri.parse('${Constants.baseUrl}/Jelo/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Jelo.fromJson(data);
    } else {
      throw Exception('Greska prilikom dohvacanja jela');
    }
  }

  Future<List<Jelo>> get(dynamic searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Jelo");

    if (searchObject != null) {
      final restoranId = searchObject['RestoranId'];
      final kategorijaId = searchObject['KategorijaId'];
      final arhivirano = searchObject['Arhivirano'];

      if (restoranId != null) {
        url = Uri.parse("${Constants.baseUrl}/Jelo?RestoranId=$restoranId");

        if (kategorijaId != null) {
          url = url.replace(queryParameters: {
            'RestoranId': restoranId.toString(),
            'KategorijaId': kategorijaId.toString(),
          });
        }
        if (arhivirano != null) {
          url = url.replace(queryParameters: {
            'RestoranId': restoranId.toString(),
            'Arhivirano': arhivirano.toString(),
          });
        }
      } else if (arhivirano != null) {
        url = Uri.parse("${Constants.baseUrl}/Jelo?Arhivirano=$arhivirano");
      }
    }

    var response = await http!.get(url);
    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<Jelo> list = data.map((x) => Jelo.fromJson(x)).cast<Jelo>().toList();
      return list;
    } else {
      throw Exception("Greska");
    }
  }

  Future<Jelo> insert(Jelo insertData) async {
    var url = Uri.parse("${Constants.baseUrl}/Jelo");
    final token = await _getToken();

    var response = await http!.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(insertData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Jelo.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to insert Jelo');
    }
  }

  Future<Jelo> update(int jeloId, Jelo updateData) async {
    var url = Uri.parse("${Constants.baseUrl}/Jelo/$jeloId");
    final token = await _getToken();

    var response = await http!.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Jelo.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update Jelo');
    }
  }

  Future<void> deleteJelo(int jeloId) async {
    final url = Uri.parse("${Constants.baseUrl}/Jelo/$jeloId");
    final token = await _getToken();

    await http!.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  Future<Jelo> updateArhivirano(int jeloId, Jelo jelo) async {
    var url = Uri.parse("${Constants.baseUrl}/Jelo/$jeloId/UpdateArhivirano");
    final token = await _getToken();

    var response = await http!.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(jelo.toJson()),
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Jelo.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update Jelo');
    }
  }
}
