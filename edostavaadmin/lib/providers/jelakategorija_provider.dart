import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

import '../constants/global_variables.dart';
import '../models/jelokategorija.dart';

class JeloKategorijaProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;

  JeloKategorijaProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<JeloKategorija> insert(JeloKategorija insertData) async {
    var url = Uri.parse("${Constants.baseUrl}/JelaKategorija");

    var response = await http!.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(insertData.toJson()),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return JeloKategorija.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to insert JeloKategorija');
    }
  }

  Future<JeloKategorija> update(
      int id, int jeloId, int newKategorijaIds) async {
    var url = Uri.parse("${Constants.baseUrl}/JelaKategorija/$id");

    var response = await http!.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jeloId': jeloId,
        'kategorijaId': newKategorijaIds,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return JeloKategorija.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update JeloKategorija');
    }
  }

  Future<int?> getIdByJeloAndKategorija(int jeloId, int kategorijaId) async {
    try {
      final jeloKategorije =
          await get({'jeloId': jeloId, 'kategorijaId': kategorijaId});

      if (jeloKategorije.isNotEmpty) {
        return jeloKategorije[0].jeloKategorijaId;
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting JeloKategorija id: $e');
      return null;
    }
  }

  Future<List<JeloKategorija>> get(dynamic searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/JelaKategorija");

    if (searchObject != null) {
      final jeloId = searchObject['jeloId'];
      final kategorijaId = searchObject['kategorijaId'];

      if (jeloId != null && kategorijaId != null) {
        url = Uri.parse(
            "${Constants.baseUrl}/JelaKategorija?jeloId=$jeloId&kategorijaId=$kategorijaId");
      } else if (jeloId != null) {
        url = Uri.parse("${Constants.baseUrl}/JelaKategorija?jeloId=$jeloId");
      } else if (kategorijaId != null) {
        url = Uri.parse(
            "${Constants.baseUrl}/JelaKategorija?kategorijaId=$kategorijaId");
      }
    }

    var response = await http!.get(url);

    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<JeloKategorija> list = data
          .map((x) => JeloKategorija.fromJson(x))
          .cast<JeloKategorija>()
          .toList();
      return list;
    } else {
      throw Exception("Error fetching JeloKategorija");
    }
  }
}
