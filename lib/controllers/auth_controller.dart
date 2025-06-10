import 'package:flutter/material.dart';
import '../database/admin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/login_screen.dart';
import '../views/bottom_navbar.dart';

class AuthController {
  final AdminService _adminService = AdminService();
  static const int _cipherKey = 5;

  String _encryptPassword(String password) {
    // Inisialisasi string kosong untuk menyimpan password yang sudah dienkripsi
    String encryptedPassword = '';

    // Loop melalui setiap karakter dalam password
    for (int i = 0; i < password.length; i++) {
      // Mendapatkan kode ASCII dari karakter saat ini
      int charCode = password.codeUnitAt(i);

      // Jika karakter adalah huruf besar (A-Z)
      if (charCode >= 65 && charCode <= 90) {
        encryptedPassword +=
            // Geser karakter dan tambahkan ke string yang dienkripsi
            String.fromCharCode((charCode - 65 + _cipherKey) % 26 + 65);
      }
      // Jika karakter adalah huruf kecil (a-z)
      else if (charCode >= 97 && charCode <= 122) {
        encryptedPassword +=
            // Geser karakter dan tambahkan ke string yang dienkripsi
            String.fromCharCode((charCode - 97 + _cipherKey) % 26 + 97);
      }
      // Jika karakter bukan huruf
      else {
        // Tambahkan karakter tanpa perubahan
        encryptedPassword += password[i];
      }
    }
    // Mengembalikan password yang sudah dienkripsi
    return encryptedPassword;
  }


  // Fungsi untuk mendekripsi password yang dienkripsi menggunakan cipher substitusi sederhana.
  String _decryptPassword(String encryptedPassword) {
    String decryptedPassword = '';
    for (int i = 0; i < encryptedPassword.length; i++) {
      int charCode = encryptedPassword.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        // Jika karakter adalah huruf besar, geser kode karakter berdasarkan _cipherKey
        decryptedPassword +=
            String.fromCharCode((charCode - 65 - _cipherKey) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        // Jika karakter adalah huruf kecil, geser kode karakter berdasarkan _cipherKey
        decryptedPassword +=
            String.fromCharCode((charCode - 97 - _cipherKey) % 26 + 97);
      } else {
        // Jika karakter bukan huruf, langsung dimasukkan ke dalam hasil dekripsi
        decryptedPassword += encryptedPassword[i];
      }
    }
    return decryptedPassword;
  }


  Future<void> login(
      BuildContext context, String username, String password) async {
    try {
      // Verifikasi kredensial login
      final response =
          await _adminService.verifyLogin(username, _encryptPassword(password));
      if (response != null) {
        // Jika login berhasil, simpan ID admin dan username dalam SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('admin_id', response.id);
        prefs.setString('admin_username', response.username);
        print('Login berhasil');
        // Arahkan ke layar BottomNavbar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return BottomNavbar();
          }),
        );
      } else {
        // Jika login gagal, cetak pesan kesalahan dan lempar exception
        print('Kredensial tidak valid');
        throw ('Username atau password tidak valid');
      }
    } catch (e) {
      // Tangkap semua kesalahan dan tampilkan pesan Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat login: $e'),
        ),
      );
      print('Error saat login: $e');
    }
  }


  Future<bool> verifyAdmin(
      BuildContext context, String username, String password) async {
    try {
      // Memverifikasi kredensial admin
      final response = await _adminService.verifyLogin(username, password);
      if (response != null) {
        return true;
      } else {
        // Jika kredensial tidak valid, cetak pesan kesalahan dan lempar exception
        print('Kredensial tidak valid');
        throw ('Username atau password tidak valid');
      }
    } catch (e) {
      // Tangkap semua kesalahan dan tampilkan pesan Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat verifikasi: $e'),
        ),
      );
      return false;
    }
  }


  Future<void> register(
      BuildContext context, String username, String password) async {
    try {
      // Enkripsi password sebelum mendaftarkan
      final encryptedPassword = _encryptPassword(password);
      // Mendaftarkan admin baru
      final response =
          await _adminService.register(username, encryptedPassword);
      if (response) {
        // Jika pendaftaran berhasil, tampilkan pesan sukses dan arahkan ke layar LoginScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran berhasil'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return LoginScreen();
          }),
        );

        print('Pendaftaran berhasil');
      } else {
        // Jika pendaftaran gagal, lemparkan exception
        throw ('Pendaftaran gagal');
      }
    } catch (e) {
      // Tangkap semua kesalahan dan tampilkan pesan Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat mendaftar: $e'),
        ),
      );
      print('Error saat mendaftar: $e');
    }
  }


  String getEncryptedPassword(String password) {
    // Mendapatkan versi terenkripsi dari password
    return _encryptPassword(password);
  }

  String getDecryptedPassword(String encryptedPassword) {
    // Mendapatkan versi terdekripsi dari password yang terenkripsi
    return _decryptPassword(encryptedPassword);
  }

  Future<String?> getUsername() async {
    // Mendapatkan username admin dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_username');
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return LoginScreen();
      }),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout Success'),
      ),
    );
  }

  Future<String?> getEncryptedPasswordFromDB(String username) async {
    // Mendapatkan password terenkripsi dari database berdasarkan username
    final encryptedPassword =
        await _adminService.getPasswordByUsername(username);
    return encryptedPassword;
  }


  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('admin_id');
    } catch (e) {
      print('isLogin Error : $e');
      return false;
    }
  }

  Future<bool> isAdminExist() async {
    try {
      return _adminService.checkAdminExist();
    } catch (e) {
      print('is admin exist Error : $e');
      return false;
    }
  }
}
