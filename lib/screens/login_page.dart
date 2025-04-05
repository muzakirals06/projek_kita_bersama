import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidasi/services/auth_service.dart'; // Ganti dengan path yang sesuai
import 'home_page.dart'; // Ganti dengan path yang sesuai
import 'register_page.dart'; // Ganti dengan path yang sesuai

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Tangani tombol kembali
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Menutup keyboard saat tap di luar input
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Agar scroll berfungsi penuh
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.amber.shade700,
                    Colors.amber.shade200
                  ], // Gradasi warna kuning
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50), // Jeda atas
                    Image.asset('assets/img/sidasi.png',
                        height: 200), // Logo SIDASI
                    SizedBox(height: 10),
                    Text(
                      "HELLO",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email Address',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value!.isEmpty ? "Masukkan email" : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Masukkan password" : null,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Login',
                                    style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text('Daftar',
                                style: TextStyle(color: Colors.white)),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      int statusCode = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (statusCode == 200) {
        _showSnackbar("Login berhasil", Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (statusCode == 401) {
        _showSnackbar(
            "Tidak dapat login, periksa email dan sandi Anda", Colors.orange);
      } else {
        _showSnackbar("Login error", Colors.red);
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Keluar"),
            content: Text("Yakin mau keluar?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Keluar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
