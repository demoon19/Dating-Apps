import 'package:flutter/material.dart';
import '../services/base_network.dart';

class ConversionController extends ChangeNotifier {
  final BaseNetwork _baseNetwork = BaseNetwork();

  // Daftar state yang akan dikelola
  String _selectedCity = 'Asia/Jakarta'; // Nilai default diubah ke Jakarta
  String _selectedCurrency = 'USD';
  double _selectedRate = 1.0;
  List<dynamic> _timezones = [];
  Map<String, dynamic> _currencies = {};

  bool _isLoadingTimezone = true;
  bool _isLoadingCurrency = true;

  // Getters untuk mengakses state dari UI dengan aman
  String get selectedCity => _selectedCity;
  String get selectedCurrency => _selectedCurrency;
  double get selectedRate => _selectedRate;
  List<dynamic> get timezones => _timezones;
  Map<String, dynamic> get currencies => _currencies;
  bool get isLoadingTimezone => _isLoadingTimezone;
  bool get isLoadingCurrency => _isLoadingCurrency;

  // Constructor: Panggil fungsi untuk memuat data saat controller dibuat
  ConversionController() {
    loadInitialData();
  }

  void loadInitialData() {
    loadTimezones();
    loadCurrency();
  }

  // --- Metode untuk mengubah state dari UI ---

  void onCityChanged(String newCity) {
    _selectedCity = newCity;
    notifyListeners(); // Beri tahu UI bahwa ada perubahan
  }

  void onCurrencyChanged(String newCurrency) {
    _selectedCurrency = newCurrency;
    if (_currencies.containsKey(newCurrency)) {
      _selectedRate = _currencies[newCurrency]!;
    }
    notifyListeners(); // Beri tahu UI bahwa ada perubahan
  }

  // --- Metode untuk mengambil data dari API ---

  Future<void> loadTimezones() async {
    _isLoadingTimezone = true;
    notifyListeners();
    try {
      _timezones = await _baseNetwork.fetchTimezone();
    } catch (e) {
      print("Error memuat zona waktu: $e");
      _timezones = []; // Atur ke daftar kosong jika gagal
    }
    _isLoadingTimezone = false;
    notifyListeners();
  }

  Future<void> loadCurrency() async {
    _isLoadingCurrency = true;
    notifyListeners();
    try {
      _currencies = await _baseNetwork.fetchCurrency();
      if (_currencies.containsKey(_selectedCurrency)) {
        _selectedRate = _currencies[_selectedCurrency]!;
      }
    } catch (e) {
      print("Error memuat mata uang: $e");
      _currencies = {}; // Atur ke map kosong jika gagal
    }
    _isLoadingCurrency = false;
    notifyListeners();
  }
  
  // Fungsi ini tetap di sini untuk dipanggil dari UI
  Future<dynamic> getTimeForZone(String zone) async {
    try {
      return await _baseNetwork.fetchTime(zone);
    } catch (e) {
      print("Error memuat waktu: $e");
      return null;
    }
  }
}