// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:dental/pages/home.dart';
import 'package:dental/services/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  final TextEditingController url = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String companyName = '';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userList = prefs.getStringList('userList') ?? [];
    if (userList.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  login() async {
    final data = {"username": username.text, "password": password.text};

    var response = await authService.login(data, url.text);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var user_id = data['user_information']['id'];
      var token = data['authorization']['token'];

      getUserImage(token, user_id, url.text);

      final userInfo = {
        "api": url.text,
        "companyName": companyName,
        "active": true,
        "token": data['authorization']['token'],
        "userId": data['user_information']['id'],
        "userName": username.text,
        "name": data['user_information']['name'],
        "image": userImage,
        "permissions": data['user_information']['operations']
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? userList = prefs.getStringList('userList') ?? [];
      userList.add(jsonEncode(userInfo));
      prefs.setStringList('userList', userList);

      var res = prefs.getStringList('userList');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['message'].toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  getUserImage(token, id, uri) async {
    var res = await authService.getUserImage(token, id, uri);
    if (res.statusCode == 200) {
      print('Success');
      setState(() {
        userImage = base64Encode(res.bodyBytes);
      });
    } else {
      print('Error');
    }
  }

  checkURL() async {
    try {
      var response = await authService.checkURL(url.text);
      setState(() {
        companyName = response[0]['company_name'];
      });
      login();
    } catch (error) {
      String errorMessage = error.toString();
      if (error is Exception) {
        errorMessage = error.toString().replaceFirst('Exception:', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(54, 135, 147, 1),
        title: const Text(
          'DPMS',
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: url,
              decoration: InputDecoration(
                labelText: 'Base URL',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(226, 232, 240, 1),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: username,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(226, 232, 240, 1),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: password,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(226, 232, 240, 1),
                    width: 1.0,
                  ),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => checkURL(),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
