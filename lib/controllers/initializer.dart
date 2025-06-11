import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../views/register_screen.dart';
import '../views/login_screen.dart';
// Import halaman dating
import '../views/dating/page_dating_home.dart';

class Initializer extends StatefulWidget {
  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  final AuthController _authController = AuthController();
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final isAdminExist = await _authController.isAdminExist();
    final isAdminLoggedIn = await _authController.isLoggedIn();

    if (!mounted) return; // Pastikan widget masih ada di tree

    if (!isAdminExist) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    } else if (!isAdminLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Jika admin sudah ada dan sudah masuk, arahkan ke halaman dating
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DatingHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}