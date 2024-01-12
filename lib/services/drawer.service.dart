import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class DrawerService {
  Future<Uint8List> fetchBlobImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userList = prefs.getStringList('userList') ?? [];
    String? api;
    String? token;
    for (String userInfoString in userList) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoString);
      if (userInfo['active'] == true) {
        token = userInfo['token'];
        api = userInfo['api'];
        break;
      }
    }

    final Uint8List error = Uint8List(10);

    String apiUrl =
        '$api/master/profilePics/2'; // Replace with your API endpoint

    try {
      http.Response response = await http.get(Uri.parse(apiUrl), headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
        "origin": "http://182.93.83.242:5002"
      });
      print('test');
      print(response.body);
      if (response.statusCode == 200) {
        // Successful API request
        Uint8List responseData = Uint8List.fromList(response.bodyBytes);
        return responseData;
      } else {
        // Handle errors
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return error;
      }
    } catch (err) {
      print('Error: $err');
      return error;
    }
  }
}
