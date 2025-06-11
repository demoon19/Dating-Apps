// lib/views/login_screen.dart

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart'; // <-- Import ditambahkan untuk halaman registrasi

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF424242),
      appBar: AppBar(
        backgroundColor: Color(0xFF585752),
        // Menghilangkan tombol kembali karena ini halaman awal sesi
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0F1DA),
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  'assets/img/login-illustration.jpg',
                  height: 180,
                ),
                SizedBox(height: 50),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Color(0xFFF0F1DA)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFa7a597)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFa7a597)),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFFF0F1DA)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color(0xFFF0F1DA)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFa7a597)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFa7a597)),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Color(0xFFF0F1DA)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      _authController.login(context, username, password);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFb2855d), // Warna latar belakang tombol
                    foregroundColor: Colors.white, // Warna teks tombol
                  ),
                  child: Text('Login'),
                ),

                // --- FITUR NAVIGASI REGISTRASI DITAMBAHKAN DI SINI ---
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: TextStyle(color: Color(0xFFF0F1DA)),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Arahkan ke halaman registrasi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Daftar sekarang',
                        style: TextStyle(
                          color: Color(0xFFb2855d),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                // --- BATAS PENAMBAHAN FITUR ---
              ],
            ),
          ),
        ),
      ])),
    );
  }
}
