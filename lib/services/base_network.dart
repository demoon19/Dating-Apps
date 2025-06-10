import 'package:http/http.dart' as http;
import 'dart:convert';

class BaseNetwork {
  // Fungsi untuk mengambil daftar zona waktu yang tersedia dari API TimeAPI
Future<dynamic> fetchTimezone() async {
  // URL endpoint API TimeAPI untuk mendapatkan daftar zona waktu
  String url = "https://timeapi.io/api/TimeZone/AvailableTimeZones";

  // Melakukan panggilan HTTP GET ke URL
  final response = await http.get(Uri.parse(url));

  // Memeriksa status kode respons
  if (response.statusCode == 200) {
    // Jika respons berhasil (status kode 200), mengurai body respons dari format JSON
    var bodyDecoded = jsonDecode(response.body);
    // Mengembalikan hasil yang telah diurai
    return bodyDecoded;
  } else {
    // Jika respons tidak berhasil, melemparkan exception dengan pesan kesalahan
    throw Exception('failed to fetch timezone');
  }
}


  // Fungsi untuk mengambil waktu dari zona waktu tertentu dari API TimeAPI
  Future<dynamic> fetchTime(String zone) async {
    // Membentuk URL endpoint API TimeAPI dengan zona waktu yang ditentukan
    String url = "https://timeapi.io/api/Time/current/zone?timeZone=${zone}";

    // Melakukan panggilan HTTP GET ke URL
    final response = await http.get(Uri.parse(url));

    // Memeriksa status kode respons
    if (response.statusCode == 200) {
      // Jika respons berhasil (status kode 200), mengurai body respons dari format JSON
      var bodyDecoded = jsonDecode(response.body);
      // Mengembalikan hasil yang telah diurai
      return bodyDecoded;
    } else {
      // Jika respons tidak berhasil, melemparkan exception dengan pesan kesalahan
      throw Exception('failed to fetch time');
    }
  }


  // Fungsi untuk mengambil data kurs mata uang terkini dari API ExchangeRate-API
  Future<dynamic> fetchCurrency() async {
    // URL endpoint API ExchangeRate-API untuk mendapatkan data kurs mata uang terkini
    String url =
        "https://v6.exchangerate-api.com/v6/fe4e52059eeb81f211dac145/latest/IDR";

    // Melakukan panggilan HTTP GET ke URL
    final response = await http.get(Uri.parse(url));

    // Memeriksa status kode respons
    if (response.statusCode == 200) {
      // Jika respons berhasil (status kode 200), mengurai body respons dari format JSON
      var bodyDecoded = jsonDecode(response.body);
      // Mengembalikan bagian 'conversion_rates' dari hasil yang telah diurai
      return bodyDecoded['conversion_rates'];
    } else {
      // Jika respons tidak berhasil, melemparkan exception dengan pesan kesalahan
      throw Exception('failed to fetch currency');
    }
  }

}
