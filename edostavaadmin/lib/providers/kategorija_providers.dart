import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

import '../constants/global_variables.dart';
import '../models/kategorija.dart';

class KategorijaProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  KategorijaProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<List<Kategorija>> get(dynamic searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Kategorija");

    if (searchObject != null) {
      url = Uri.parse(
          "${Constants.baseUrl}/Kategorija?RestoranId=${searchObject['RestoranId']}");
    }

    var response = await http!.get(url);

    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<Kategorija> list =
          data.map((x) => Kategorija.fromJson(x)).cast<Kategorija>().toList();
      return list;
    } else {
      throw Exception("User not allowed");
    }
  }

  Future<Kategorija> update(int kategorijaId, Kategorija updateData) async {
    var url = Uri.parse("${Constants.baseUrl}/Kategorija/$kategorijaId");

    var response = await http!.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Kategorija.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update Kategorija');
    }
  }

  Future<Kategorija> insert(Kategorija insertData) async {
    var url = Uri.parse("${Constants.baseUrl}/Kategorija");

    var response = await http!.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(insertData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Kategorija.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to insert Kategorija');
    }
  }

  Future<void> deleteKategorija(int kategorijaId) async {
    final url = Uri.parse("${Constants.baseUrl}/Kategorija/$kategorijaId");

    await http!.delete(url);
  }
}
