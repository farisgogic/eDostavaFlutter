import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

import '../constants/global_variables.dart';
import '../models/restoran.dart';

class RestoranProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  RestoranProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<List<Restoran>> get(Map<String, dynamic> searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Restoran");

    if (searchObject['naziv'] != null && searchObject['korisnikId'] != null) {
      url = Uri.parse(
        "${Constants.baseUrl}/Restoran?Naziv=${searchObject['naziv']}&korisnikId=${searchObject['korisnikId']}",
      );
    } else if (searchObject['naziv'] != null) {
      url = Uri.parse(
          "${Constants.baseUrl}/Restoran?Naziv=${searchObject['naziv']}");
    } else if (searchObject['korisnikId'] != null) {
      url = Uri.parse(
          "${Constants.baseUrl}/Restoran?korisnikId=${searchObject['korisnikId']}");
    }

    var response = await http!.get(url);

    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<Restoran> list =
          data.map((x) => Restoran.fromJson(x)).cast<Restoran>().toList();
      return list;
    } else {
      throw Exception("User not allowed");
    }
  }

  Future<Restoran> update(int restoranId, Restoran updateData) async {
    var url = Uri.parse("${Constants.baseUrl}/Restoran/$restoranId");

    var response = await http!.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Restoran.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update Restoran');
    }
  }

  Future<Restoran> getById(int id) async {
    final response =
        await http!.get(Uri.parse('${Constants.baseUrl}/Restoran/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Restoran.fromJson(data);
    } else {
      throw Exception('Greska prilikom dohvacanja restorana');
    }
  }
}
