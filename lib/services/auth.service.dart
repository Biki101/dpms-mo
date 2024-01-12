// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // final String baseUrl = "http://182.93.83.242:9002";
  var token;

  Future login(data, baseUrl) async {
    print(baseUrl);
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future getUserImage(token, id, baseUrl) async {
    print('$baseUrl/master/profilePics/$id');
    final response = await http.get(
      Uri.parse('$baseUrl/master/profilePics/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token'
      },
    );
    return response;
  }

  Future checkURL(baseUrl) async {
    final response = await http.get(
      Uri.parse('$baseUrl/master/generalSettings/getInformation'),
      headers: {
        "Content-Type": "application/json",
      },
    ).timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Invalid URL');
    }
  }

  Future<Map<String, dynamic>?> getActiveUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userList = prefs.getStringList('userList') ?? [];
    Map<String, dynamic>? activeUser;
    for (String userInfoString in userList) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoString);
      if (userInfo['active'] == true) {
        activeUser = userInfo;
        token = userInfo['token'];
        break;
      }
    }
    return activeUser;
  }

  isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
