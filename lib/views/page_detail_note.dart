import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/conversion_controller.dart';
import '../../model/financial_model.dart';
import '../../database/DatabaseHelper.dart';
import '../views/page_input_income.dart';
import '../views/page_input_expense.dart';
import '../../controllers/other_controllers.dart';
import '../../services/notification_service.dart'; // Import service notifikasi

class DetailNote extends StatefulWidget {
  final FinancialModel financialModel;

  const DetailNote({Key? key, required this.financialModel}) : super(key: key);

  @override
  _DetailNoteState createState() => _DetailNoteState();
}

class _DetailNoteState extends State<DetailNote> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final OtherController otherController = OtherController();
  late final ConversionController _conversionController;

  @override
  void initState() {
    super.initState();
    _conversionController = ConversionController();
  }

  @override
  void dispose() {
    _conversionController.dispose();
    super.dispose();
  }

  // --- Fungsi inti (delete, edit, open maps) ---
  Future<void> deleteData(FinancialModel financialModel) async {
    var result = await databaseHelper.deleteTransaksi(
        financialModel.id!, financialModel.tipe!);
    if (result != null && result > 0) {
      print('Data berhasil dihapus');

      // Tampilkan notifikasi
      NotificationService.showNotification(
          id: financialModel.id!,
          title: "Catatan Dihapus",
          body: "Catatan '${financialModel.keterangan}' telah dihapus.");

      if (!mounted) return;
      // Kembali ke halaman sebelumnya setelah data dihapus
      Navigator.pop(context, 'deleted');
    }
  }

  Future<void> editData(BuildContext context, String type,
      FinancialModel financialModel) async {
    var result;
    if (type == 'pengeluaran') {
      result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PageInputExpense(financialModel: financialModel)));
    } else if (type == 'pemasukan') {
      result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PageInputIncome(financialModel: financialModel)));
    }
    if (result == 'update') {
      if (!mounted) return;
      // Cukup pop, karena halaman list akan refresh otomatis
      Navigator.pop(context, 'updated');
    }
  }

  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri _url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(_url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tidak dapat membuka peta')));
    }
  }

  // Sisa kode build widget tidak berubah
  @override
  Widget build(BuildContext context) {
    // ...
    // ... (kode dari _buildDetailCard hingga _confirmDelete tetap sama)
    // ...
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF585752),
        title: const Text('Detail Catatan'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _conversionController,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailCard(),
                const SizedBox(height: 16),
                if (widget.financialModel.latitude != null &&
                    widget.financialModel.longitude != null)
                  _buildLocationCard(),
                const SizedBox(height: 16),
                _buildConversionCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.financialModel.keterangan!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.financialModel.tipe == 'pemasukan'
                    ? Colors.green.shade300
                    : Colors.red.shade300,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(
                Icons.paid,
                'Jumlah Uang',
                OtherController.convertToIdr(
                    int.parse(widget.financialModel.jml_uang!))),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.calendar_today, 'Tanggal', widget.financialModel.tanggal!),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time_filled, 'Dibuat Pada',
                otherController.formatTime(widget.financialModel.createdAt!)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue.shade300),
                    onPressed: () => editData(
                        context, widget.financialModel.tipe!, widget.financialModel),
                    tooltip: 'Edit'),
                const SizedBox(width: 8),
                IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade400),
                    onPressed: () =>
                        _confirmDelete(context, widget.financialModel),
                    tooltip: 'Hapus'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lokasi Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(Icons.location_on, 'Koordinat',
                'Lat: ${widget.financialModel.latitude!.toStringAsFixed(4)}, Lon: ${widget.financialModel.longitude!.toStringAsFixed(4)}'),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(
                      widget.financialModel.latitude!,
                      widget.financialModel.longitude!),
                  icon: const Icon(Icons.map),
                  label: const Text('Buka di Google Maps'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fitur Konversi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24, thickness: 1),
            const Text("Konversi Waktu (GMT)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.schedule, 'Waktu Lokal', otherController.currentTime()),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.public, size: 20, color: Colors.white70),
                const SizedBox(width: 16),
                const Text('Pilih Zona Waktu:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                Expanded(
                  child: _conversionController.isLoadingTimezone
                      ? const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : DropdownButton<String>(
                          value: _conversionController.selectedCity,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF585752),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _conversionController.onCityChanged(newValue);
                            }
                          },
                          items: _conversionController.timezones
                              .map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()));
                          }).toList(),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () => _showTimeConversionResult(),
                child: const Text('Tampilkan Waktu Terkonversi'),
              ),
            ),
            const Divider(height: 32, thickness: 1),
            const Text("Konversi Mata Uang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.attach_money,
                "Dari IDR",
                OtherController.convertToIdr(
                    int.parse(widget.financialModel.jml_uang!))),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.currency_exchange,
                    size: 20, color: Colors.white70),
                const SizedBox(width: 16),
                const Text('Ke Mata Uang:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                Expanded(
                  child: _conversionController.isLoadingCurrency
                      ? const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : DropdownButton<String>(
                          value: _conversionController.selectedCurrency,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF585752),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _conversionController.onCurrencyChanged(newValue);
                            }
                          },
                          items: _conversionController.currencies.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.price_check,
                'Hasil Konversi',
                otherController.formatAmount(
                    _conversionController.selectedCurrency,
                    double.parse(widget.financialModel.jml_uang!) *
                        _conversionController.selectedRate)),
          ],
        ),
      ),
    );
  }

  void _showTimeConversionResult() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: _conversionController
              .getTimeForZone(_conversionController.selectedCity),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return AlertDialog(
                backgroundColor: const Color(0xFF424242),
                content: Text(
                    'Gagal memuat data waktu untuk ${_conversionController.selectedCity}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else {
              final timeData = snapshot.data as Map<String, dynamic>;
              return AlertDialog(
                backgroundColor: const Color(0xFF424242),
                title: Text('Waktu di ${_conversionController.selectedCity}',
                    style: const TextStyle(color: Color(0xFFF2EFCD))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal: ${timeData['date']}',
                        style:
                            const TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                    Text('Waktu: ${timeData['time']}',
                        style:
                            const TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                    Text('Zona: ${timeData['timeZone']}',
                        style:
                            const TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup')),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 16),
        Text('$label:', style: const TextStyle(color: Colors.white70)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, FinancialModel financialModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF424242),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Color(0xFFF4EFC2))),
        title: const Text('Hapus Data', style: TextStyle(color: Color(0xFFF2EFCD))),
        content: const Text('Yakin ingin menghapus data ini?',
            style: TextStyle(color: Color(0xFFF2EFCD))),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteData(financialModel);
              },
              child: Text('Ya', style: TextStyle(color: Colors.red.shade300))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tidak', style: TextStyle(color: Color(0xFFF2EFCD)))),
        ],
      ),
    );
  }
}