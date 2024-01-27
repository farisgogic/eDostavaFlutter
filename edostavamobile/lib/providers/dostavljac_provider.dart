import 'package:edostavamobile/features/Auth/models/dostavljac.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';

import '../constants/global_variables.dart';

class DostavljacProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  DostavljacProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<Dostavljac> getById(int id) async {
    try {
      final response =
          await http!.get(Uri.parse('${Constants.baseUrl}/Dostavljac/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Dostavljac.fromJson(data);
      } else {
        throw Exception('Failed to load dostavljac');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Dostavljac> update(int id, Dostavljac update) async {
    final response = await http!.put(
      Uri.parse('${Constants.baseUrl}/Dostavljac/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(update.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedKupac = Dostavljac.fromJson(json.decode(response.body));
      return updatedKupac;
    } else {
      throw Exception('Failed to update dostavljac');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    if (jwt != null) {
      final bytes = utf8.encode('jwt:$jwt');
      final base64Str = base64.encode(bytes);
      final authHeader = 'Basic $base64Str';
      final response = await http!.post(
        Uri.parse('${Constants.baseUrl}/Dostavljac/logout'),
        headers: <String, String>{
          'Authorization': authHeader,
        },
      );
      if (response.statusCode == 200) {
        await prefs.remove('jwt');
      } else {
        throw Exception('Greska prilikom odjave');
      }
    }
  }

  Future<dynamic> login(String username, String password) async {
    final response = await http!.post(
      Uri.parse('${Constants.baseUrl}/Dostavljac/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final token = jsonData['token'];
      if (token != null) {
        // ignore: invalid_use_of_visible_for_testing_member
        SharedPreferences.setMockInitialValues({});
        await SharedPreferences.getInstance()
            .then((prefs) => prefs.setString('jwt', token));
      }
      return Dostavljac.fromJson(jsonData['dostavljac']);
    } else if (response.statusCode == 401) {
      throw Exception('Pogresno korisnicko ime ili lozinka');
    } else {
      throw Exception('Greska prilikom logiranja');
    }
  }

  Future<int> getRoleIdForUloga(String ulogaName) async {
    try {
      final response = await http!.get(
        Uri.parse('${Constants.baseUrl}/Uloga?Naziv=$ulogaName'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final roles = jsonData as List<dynamic>;

        if (roles.isNotEmpty) {
          final roleId = roles[0]['ulogaId'] as int;
          return roleId;
        }
      }

      throw Exception('Failed to fetch role ID for Uloga: $ulogaName');
    } catch (e) {
      throw Exception('Failed to fetch role ID for Uloga: $ulogaName');
    }
  }

  Future<void> register(Dostavljac request) async {
    var url = Uri.parse("${Constants.baseUrl}/Dostavljac");
    var headers = {'Content-Type': 'application/json'};

    int roleId = await getRoleIdForUloga('dostavljac');

    request.ulogeIdList = [roleId];

    var body = jsonEncode(request);

    var response = await http!.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Neuspjesna registracija');
    }
  }

  bool isValidResponseCode(Response response) {
    if (response.statusCode == 200) {
      if (response.body != "") {
        return true;
      } else {
        return false;
      }
    } else if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception("Bad request");
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      throw Exception("Forbidden");
    } else if (response.statusCode == 404) {
      throw Exception("Not found");
    } else if (response.statusCode == 500) {
      throw Exception("Internal server error");
    } else {
      throw Exception("Exception... handle this gracefully");
    }
  }
}
