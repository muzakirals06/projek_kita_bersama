import 'package:flutter/material.dart';
import 'package:sidasi/services/auth_service.dart'; // Sesuaikan dengan path projectmu
import 'package:sidasi/screens/login_page.dart'; // Sesuaikan dengan path projectmu

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _callSignController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contractorController = TextEditingController();

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      int statusCode = await _authService.register(
        _nameController.text.trim(),
        _callSignController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _contractorController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (statusCode == 201) {
        _showSnackbar("Pendaftaran berhasil, silakan login", Colors.green);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else if (statusCode == 409) {
        _showSnackbar("User sudah ada", Colors.orange);
      } else {
        _showSnackbar("Gagal mendaftar", Colors.red);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Nama"),
                  validator: (value) =>
                      value!.isEmpty ? "Nama tidak boleh kosong" : null,
                ),
                TextFormField(
                  controller: _callSignController,
                  decoration: InputDecoration(labelText: "Call Sign"),
                  validator: (value) =>
                      value!.isEmpty ? "Call Sign tidak boleh kosong" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Nomor HP"),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? "Nomor HP tidak boleh kosong" : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty || !value.contains('@')
                      ? "Masukkan email yang valid"
                      : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? "Password minimal 6 karakter" : null,
                ),
                TextFormField(
                  controller: _contractorController,
                  decoration: InputDecoration(labelText: "Contractor"),
                  validator: (value) =>
                      value!.isEmpty ? "Contractor tidak boleh kosong" : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: Text("Daftar"),
                        ),
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("Sudah punya akun? Login di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
