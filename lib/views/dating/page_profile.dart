import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  AuthController authController = AuthController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return _buildProfile(snapshot.data!, context);
      },
    );
  }

  Future<Map<String, String>> _getUserProfile() async {
    String? username = await authController.getUsername();
    String? encryptedPassword =
        await authController.getEncryptedPasswordFromDB(username!);
    return {'username': username, 'password': encryptedPassword!};
  }

  Widget _buildProfile(Map<String, String> profileData, BuildContext context) {
    String encryptedPassword = profileData['password']!;
    String decryptedPassword =
        authController.getDecryptedPassword(encryptedPassword);
    return Scaffold(
      backgroundColor: Color(0xFF424242),
      appBar: AppBar(
        backgroundColor: Color(0xFF585752),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                'assets/img/text-logo.png',
                height: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.asset(
                'assets/img/logo.png',
                height: 60,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0F1DA),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Color.fromARGB(255, 192, 189, 160), // Warna border
                        width: 4, // Lebar border
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/img/foto.JPG'),
                      radius: 120,
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _infoProfile('Nama', 'Dewangga Mukti Wibawa'),
                      _infoProfile('NIM', '123220208'),
                      _infoProfile('Username', profileData['username']!),
                      _infoProfile('Password Enkripsi', encryptedPassword),
                      _infoProfile('Password Deskripsi', decryptedPassword),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      authController.logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoProfile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
