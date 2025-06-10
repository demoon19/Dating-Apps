import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherController {
    // Fungsi untuk mengonversi angka menjadi format mata uang Rupiah
  static String convertToIdr(dynamic number) {
    // Membuat objek formatter untuk format mata uang Rupiah dengan dua digit desimal
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id', // Menggunakan bahasa Indonesia
      symbol: 'Rp ', // Menambahkan simbol mata uang Rupiah
      decimalDigits: 2, // Menentukan jumlah digit desimal
    );
    // Mengembalikan angka yang telah dikonversi menjadi format mata uang Rupiah
    return currencyFormatter.format(number);
  }


  // Fungsi untuk membuka tautan website di tab baru
  Future<void> launchURL(String url) async {
    // Membuat URI dari URL yang diberikan
    final Uri _url = Uri.parse(url);
    // Mengecek apakah tautan website dapat dibuka
    if (!await launchUrl(_url)) {
      // Jika tautan tidak dapat dibuka, lemparkan exception
      throw Exception('Could not launch $url');
    }
  }

  // Fungsi untuk mendapatkan waktu saat ini dalam format 'HH:MM WIB'
  String currentTime() {
    // Mendapatkan waktu saat ini
    DateTime now = DateTime.now();
    // Membuat string waktu dalam format yang diinginkan dengan menambahkan leading zero pada jam dan menit
    String currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    // Mengembalikan waktu saat ini dalam format yang telah diformat
    return currentTime;
  }


 // Fungsi untuk menampilkan informasi zona waktu dan jumlah uang
  String formatAmount(String zone, double amount) {
    // Mengonversi jumlah uang menjadi string dengan dua digit desimal
    String _amount = amount.toStringAsFixed(2);
    // Mengembalikan string yang berisi informasi zona waktu dan jumlah uang
    return "Uang dalam ${zone} : ${_amount}";
  }


  // Fungsi untuk memformat string tanggal dan waktu ke format yang lebih mudah dibaca
  String formatTime(String dateTimeString) {
    // Membuat objek DateTime dari string tanggal dan waktu
    DateTime dateTime = DateTime.parse(dateTimeString);
    // Mendapatkan bagian-bagian dari tanggal dan waktu
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    // Mengembalikan string yang memformat tanggal dan waktu ke format yang lebih mudah dibaca
    return '$day-$month-$year, $hour:$minute:$second WIB';
  }

}
