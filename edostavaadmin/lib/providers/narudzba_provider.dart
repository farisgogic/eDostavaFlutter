import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';

import '../constants/global_variables.dart';
import '../models/Narudzba.dart';

class NarudzbaProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  NarudzbaProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<Narudzba> updateNarudzba(
    int id,
    int statusNarudzbeId,
  ) async {
    final url = Uri.parse('${Constants.baseUrl}/Narudzba/$id');
    final response = await http!.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'statusNarudzbeId': statusNarudzbeId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Narudzba.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update Narudzba');
    }
  }

  Future<List<Narudzba>> get(Map<String, dynamic> searchObject) async {
    var url = Uri.parse("${Constants.baseUrl}/Narudzba");

    if (searchObject['RestoranId'] != null && searchObject['kupacId'] != null) {
      url = Uri.parse(
        "${Constants.baseUrl}/Narudzba?RestoranId=${searchObject['RestoranId']}&kupacId=${searchObject['kupacId']}",
      );
    } else if (searchObject['RestoranId'] != null) {
      url = Uri.parse(
          "${Constants.baseUrl}/Narudzba?RestoranId=${searchObject['RestoranId']}");
    } else if (searchObject['kupacId'] != null) {
      url = Uri.parse(
          "${Constants.baseUrl}/Narudzba?kupacId=${searchObject['kupacId']}");
    }

    var response = await http!.get(url);
    if (response.statusCode < 400) {
      var data = jsonDecode(response.body);
      List<Narudzba> list =
          data.map((x) => Narudzba.fromJson(x)).cast<Narudzba>().toList();
      return list;
    } else {
      throw Exception("Greska");
    }
  }
}
