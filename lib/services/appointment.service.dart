import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AppointmentService {
  Future getAppointmentData(date) async {
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

    var data = {
      "filter": [
        {"field": "fromDate", "value": date},
        {"field": "toDate", "value": date},
        {"field": "systemAppointmentNo", "value": ""},
        {"field": "user_name", "value": ""},
        {"field": "patient_name", "value": ""},
        {"field": "appointmentStatus", "value": ""}
      ],
      "pagination": {"pageIndex": 0, "pageSize": 25},
      "sortDTO": [
        {"field": "date", "orderType": "desc"}
      ]
    };

    final response = await http.post(
      Uri.parse('$api/appointment/view'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      // ignore: avoid_print
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }
}
