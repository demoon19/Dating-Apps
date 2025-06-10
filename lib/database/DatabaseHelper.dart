import '../model/financial_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static const String finacialTable = 'tbl_keuangan';
  static const String financialId = 'id';
  static const String financialTipe = 'tipe';
  static const String financialKet = 'keterangan';
  static const String financialJmlUang = 'jml_uang';
  static const String financialTgl = 'tanggal';
  static const String financialCreated = 'createdAt';
  static const String financialLatitude = 'latitude'; // Ditambahkan
  static const String financialLongitude = 'longitude'; // Ditambahkan

  static const String userTable = 'tbl_user';
  static const String userId = 'id';
  static const String username = 'username';
  static const String password = 'password';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database?> get checkDB async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB();
    return _database;
  }

  Future<Database?> _initDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'econome.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    var sql = '''
    CREATE TABLE $finacialTable (
      $financialId INTEGER PRIMARY KEY, 
      $financialTipe TEXT,
      $financialKet TEXT,
      $financialJmlUang TEXT,
      $financialTgl TEXT,
      $financialCreated TEXT,
      $financialLatitude REAL, 
      $financialLongitude REAL
    )
    ''';
    await db.execute(sql);

    var userSql = '''
    CREATE TABLE $userTable (
      $userId INTEGER PRIMARY KEY, 
      $username TEXT,
      $password TEXT
    )
    ''';
    await db.execute(userSql);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $finacialTable ADD COLUMN $financialLatitude REAL');
      await db.execute('ALTER TABLE $finacialTable ADD COLUMN $financialLongitude REAL');
    }
  }

  Future<int?> saveData(FinancialModel financialModel) async {
    var dbClient = await checkDB;
    return await dbClient!.insert(finacialTable, financialModel.toMap());
  }

  Future<List?> getAllDataTransaction() async {
    var dbClient = await checkDB;
    var result = await dbClient!.rawQuery('SELECT * FROM $finacialTable ');
    return result.toList();
  }

  Future<int> getJmlPemasukan() async {
    var dbClient = await checkDB;
    var queryResult = await dbClient!.rawQuery('SELECT SUM(jml_uang) AS TOTAL from $finacialTable WHERE $financialTipe = ?', ['pemasukan']);
    int total = int.tryParse(queryResult[0]['TOTAL']?.toString() ?? '0') ?? 0;
    return total;
  }

  Future<int> getJmlPengeluaran() async {
    var dbClient = await checkDB;
    var queryResult = await dbClient!.rawQuery('SELECT SUM(jml_uang) AS TOTAL from $finacialTable WHERE $financialTipe = ?', ['pengeluaran']);
    int total = int.tryParse(queryResult[0]['TOTAL']?.toString() ?? '0') ?? 0;
    return total;
  }

  Future<int?> updateData(FinancialModel financialModel, String type) async {
    var dbClient = await checkDB;
    return await dbClient!.update(finacialTable, financialModel.toMap(), where: '$financialId = ? and $financialTipe = ?', whereArgs: [financialModel.id, type]);
  }

  Future<int?> cekDataDatabase() async {
    var dbClient = await checkDB;
    return Sqflite.firstIntValue(await dbClient!.rawQuery('SELECT COUNT(*) FROM $finacialTable '));
  }

  Future<int?> deleteTransaksi(int id, String type) async {
    var dbClient = await checkDB;
    return await dbClient!.delete(finacialTable, where: '$financialId = ? and $financialTipe = ?', whereArgs: [id, type]);
  }
}