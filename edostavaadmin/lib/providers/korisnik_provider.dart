import 'dart:convert';
import 'dart:io';
import 'package:edostavaadmin/constants/global_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/korisnik.dart';

class KorisnikProvider with ChangeNotifier {
  HttpClient client = HttpClient();
  IOClient? http;
  KorisnikProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<Korisnik> getById(int id) async {
    try {
      final response =
          await http!.get(Uri.parse('${Constants.baseUrl}/Korisnik/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Korisnik.fromJson(data);
      } else {
        throw Exception('Failed to load korisnik');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Korisnik> update(int id, Korisnik update) async {
    final token = await _getToken();
    final response = await http!.put(
      Uri.parse('${Constants.baseUrl}/Korisnik/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(update.toJson()),
    );
    if (response.statusCode == 200) {
      final updatedKorisnik = Korisnik.fromJson(json.decode(response.body));
      return updatedKorisnik;
    } else {
      throw Exception('Failed to update korisnik');
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

  Future<void> register(Korisnik request) async {
    var url = Uri.parse("${Constants.baseUrl}/Korisnik");
    var headers = {'Content-Type': 'application/json'};

    int roleId = await getRoleIdForUloga('uposlenik');

    request.ulogeIdList = [roleId];

    var body = jsonEncode(request);

    var response = await http!.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Neuspjesna registracija');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    if (jwt != null) {
      final response = await http!.post(
        Uri.parse('${Constants.baseUrl}/Korisnik/logout'),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
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
      Uri.parse('${Constants.baseUrl}/Korisnik/login'),
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
      return Korisnik.fromJson(jsonData['korisnik']);
    } else if (response.statusCode == 401) {
      throw Exception('Pogresno korisnicko ime ili lozinka');
    } else {
      throw Exception('Greska prilikom logiranja');
    }
  }
}
