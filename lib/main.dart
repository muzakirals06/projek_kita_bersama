import 'package:flutter/material.dart';
import 'package:sidasi/screens/login_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidasi/services/dialog_service.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  String? sessionToken = prefs.getString('session_token');

  bool isLoggedIn = false;

  // Validasi ke server jika sessionToken tidak null
  if (sessionToken != null) {
    final authService = AuthService();
    isLoggedIn = await authService.validateSession();
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: DialogService.navigatorKey,
      title: 'SIDASI App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? HomePage() : LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
