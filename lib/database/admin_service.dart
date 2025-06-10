import '../model/login.dart';
import 'package:sqflite/sqflite.dart';
import 'DatabaseHelper.dart';

class AdminService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<LoginResponse?> verifyLogin(
      String usernameParam, String passwordParam) async {
    // Mendapatkan instance dari database
    final db = await _dbHelper.checkDB;

    // Melakukan query untuk mencari pengguna dengan username dan password yang cocok
    final result = await db!.query(
      'tbl_user',
      where: 'username = ? AND password = ?',
      whereArgs: [usernameParam, passwordParam],
    );

    // Jika tidak kosong
    if (result.isNotEmpty) {
      // Mengambil ID dan username dari hasil query
      final id = result.first['id'] as int;
      final username = result.first['username'] as String;
      print(result);

      // Mengembalikan objek LoginResponse yang berisi ID dan username pengguna
      return LoginResponse(id: id, username: username);
    }

    var databasesPath = await getDatabasesPath();
    print(databasesPath);

    // Mengembalikan null jika data tidak di temukan
    return null;
  }

  Future<bool> register(String username, String password) async {
    // Mendapatkan instance dari database
    final db = await _dbHelper.checkDB;

    // Memasukkan data pengguna baru ke dalam tabel pengguna
    final result = await db!.insert(
      DatabaseHelper.userTable,
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print(result);

    var databasesPath = await getDatabasesPath();
    print(databasesPath);
    return true;
  }

  Future<bool> checkAdminExist() async {
      final db = await _dbHelper.checkDB;
      // Mendapatkan semua baris dari tabel 'tbl_user'
      final result = await db!.query('tbl_user');
      // Mengembalikan true jika terdapat baris dalam tabel
      return result.isNotEmpty;
  }

  Future<String?> getPasswordByUsername(String username) async {
    final db = await _dbHelper.checkDB;
    final result = await db!.query(
      'tbl_user',
      columns: ['password'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      // Mengembalikan password jika pengguna ditemukan
      return result.first['password'] as String?;
    }
    // Mengembalikan null jika pengguna tidak ditemukan
    return null;
  }
}
