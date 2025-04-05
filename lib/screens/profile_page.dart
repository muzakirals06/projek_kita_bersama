import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    await UserService().initializeUserData();
    await Future.delayed(Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString("session_token");
    String? csrfToken = prefs.getString("csrf_token");
    userData = await UserService().fetchUserData();
    setState(() {});
  }

  void checkTokenExpiration(String sessionToken) {
    final payload = sessionToken.split('.')[1];
    final decodedPayload = jsonDecode(utf8.decode(base64Url.decode(payload)));
    final exp = decodedPayload['exp'];

    if (DateTime.now().millisecondsSinceEpoch / 1000 > exp) {
      print("❌ Token telah kedaluwarsa.");
    } else {
      print("✅ Token masih berlaku.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama: ${userData!['name']}"),
                  Text("Email: ${userData!['email']}"),
                  Text("Telepon: ${userData!['phone']}"),
                  Text("Call Sign: ${userData!['call_sign']}"),
                  Text("Kontraktor: ${userData!['contractor']}"),
                  Text("Status: ${userData!['status']}"),
                ],
              ),
            ),
    );
  }
}