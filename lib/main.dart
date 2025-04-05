import 'package:flutter/material.dart';
import 'package:sidasi/screens/login_page.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Tambahkan ini sebelum memanggil async function
  final prefs = await SharedPreferences.getInstance();
  String? sessionToken = prefs.getString('session_token');

  runApp(MyApp(isLoggedIn: sessionToken != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIDASI App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Gunakan HomePage sebagai halaman awal
    );
  }
}
