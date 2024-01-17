import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Notificationservice {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  void initializeNotification() async {
    InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(id, title, body) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max, priority: Priority.high);

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future getNotifications() async {
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
    final response = await http.get(
      Uri.parse('$api/notice/getNotice'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
        "origin": "http://182.93.83.242:5002"
      },
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print

      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<Uint8List> fetchNoticeBlobImage(imageName) async {
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
        '$api/notice/getImageByImageName/$imageName'; // Replace with your API endpoint

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
