import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/conversion_controller.dart';
import '../../model/financial_model.dart';
import '../../database/DatabaseHelper.dart';
import '../views/page_input_income.dart';
import '../views/page_input_expense.dart';
import '../views/bottom_navbar.dart';
import '../../controllers/other_controllers.dart';

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
  // ... (kode fungsi ini tidak berubah dari sebelumnya)
  Future<void> deleteData(FinancialModel financialModel) async {
    var result = await databaseHelper.deleteTransaksi(financialModel.id!, financialModel.tipe!);
    if (result != null && result > 0) {
      print('Data berhasil dihapus');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomNavbar()), (Route<dynamic> route) => false);
    }
  }

  Future<void> editData(BuildContext context, String type, FinancialModel financialModel) async {
     var result;
    if (type == 'pengeluaran') {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageInputExpense(financialModel: financialModel)));
    } else if (type == 'pemasukan') {
      result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageInputIncome(financialModel: financialModel)));
    }
    if (result == 'update') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomNavbar()),(Route<dynamic> route) => false);
    }
  }

  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
     String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri _url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(_url)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak dapat membuka peta')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF585752),
        title: Text('Detail Catatan'),
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
                SizedBox(height: 16),
                if (widget.financialModel.latitude != null && widget.financialModel.longitude != null)
                  _buildLocationCard(),
                SizedBox(height: 16),
                _buildConversionCard(), // <-- DI SINI LETAKNYA
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard() { /* ... kode tidak berubah ... */ 
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
                color: widget.financialModel.tipe == 'pemasukan' ? Colors.green.shade300 : Colors.red.shade300,
              ),
            ),
            Divider(height: 24, thickness: 1),
            _buildInfoRow(Icons.paid, 'Jumlah Uang', OtherController.convertToIdr(int.parse(widget.financialModel.jml_uang!))),
            SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Tanggal', widget.financialModel.tanggal!),
            SizedBox(height: 12),
            _buildInfoRow(Icons.access_time_filled, 'Dibuat Pada', otherController.formatTime(widget.financialModel.createdAt!)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.blue.shade300), onPressed: () => editData(context, widget.financialModel.tipe!, widget.financialModel), tooltip: 'Edit'),
                SizedBox(width: 8),
                IconButton(icon: Icon(Icons.delete, color: Colors.red.shade400), onPressed: () => _confirmDelete(context, widget.financialModel), tooltip: 'Hapus'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() { /* ... kode tidak berubah ... */ 
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Lokasi Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(height: 24, thickness: 1),
            _buildInfoRow(Icons.location_on, 'Koordinat', 'Lat: ${widget.financialModel.latitude!.toStringAsFixed(4)}, Lon: ${widget.financialModel.longitude!.toStringAsFixed(4)}'),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openInGoogleMaps(widget.financialModel.latitude!, widget.financialModel.longitude!),
                icon: Icon(Icons.map),
                label: Text('Buka di Google Maps'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU KONVERSI (Implementasi Lengkap)
  Widget _buildConversionCard() {
     return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fitur Konversi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(height: 24, thickness: 1),

            // --- Bagian Konversi Waktu (GMT) ---
            Text("Konversi Waktu (GMT)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            _buildInfoRow(Icons.schedule, 'Waktu Lokal', otherController.currentTime()),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.public, size: 20, color: Colors.white70),
                SizedBox(width: 16),
                Text('Pilih Zona Waktu:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 8),
                Expanded(
                  child: _conversionController.isLoadingTimezone
                    ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : DropdownButton<String>(
                        value: _conversionController.selectedCity,
                        isExpanded: true,
                        dropdownColor: Color(0xFF585752),
                        onChanged: (String? newValue) {
                          if (newValue != null) _conversionController.onCityChanged(newValue);
                        },
                        items: _conversionController.timezones.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(value: value.toString(), child: Text(value.toString()));
                        }).toList(),
                      ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () => _showTimeConversionResult(),
                child: Text('Tampilkan Waktu Terkonversi'),
              ),
            ),

            Divider(height: 32, thickness: 1),

            // --- Bagian Konversi Mata Uang ---
            Text("Konversi Mata Uang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money, "Dari IDR", OtherController.convertToIdr(int.parse(widget.financialModel.jml_uang!))),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.currency_exchange, size: 20, color: Colors.white70),
                SizedBox(width: 16),
                Text('Ke Mata Uang:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 8),
                Expanded(
                  child: _conversionController.isLoadingCurrency
                    ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : DropdownButton<String>(
                        value: _conversionController.selectedCurrency,
                        isExpanded: true,
                        dropdownColor: Color(0xFF585752),
                        onChanged: (String? newValue) {
                          if (newValue != null) _conversionController.onCurrencyChanged(newValue);
                        },
                        items: _conversionController.currencies.keys.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.price_check, 'Hasil Konversi', 
              otherController.formatAmount(
                _conversionController.selectedCurrency, 
                double.parse(widget.financialModel.jml_uang!) * _conversionController.selectedRate
              )
            ),
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
          future: _conversionController.getTimeForZone(_conversionController.selectedCity),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return AlertDialog(
                backgroundColor: Color(0xFF424242),
                content: Text('Gagal memuat data waktu untuk ${_conversionController.selectedCity}', style: TextStyle(color: Colors.red)),
              );
            } else {
              final timeData = snapshot.data as Map<String, dynamic>;
              return AlertDialog(
                backgroundColor: Color(0xFF424242),
                title: Text('Waktu di ${_conversionController.selectedCity}', style: TextStyle(color: Color(0xFFF2EFCD))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal: ${timeData['date']}', style: TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                    Text('Waktu: ${timeData['time']}', style: TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                    Text('Zona: ${timeData['timeZone']}', style: TextStyle(color: Color(0xFFF2EFCD), fontSize: 16)),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup')),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) { /* ... kode tidak berubah ... */ 
      return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        SizedBox(width: 16),
        Text('$label:', style: TextStyle(color: Colors.white70)),
        SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, FinancialModel financialModel) { /* ... kode tidak berubah ... */
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF424242),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Color(0xFFF4EFC2))),
        title: Text('Hapus Data', style: TextStyle(color: Color(0xFFF2EFCD))),
        content: Text('Yakin ingin menghapus data ini?', style: TextStyle(color: Color(0xFFF2EFCD))),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); deleteData(financialModel); }, child: Text('Ya', style: TextStyle(color: Colors.red.shade300))),
          TextButton(onPressed: () { Navigator.pop(context); }, child: Text('Tidak', style: TextStyle(color: Color(0xFFF2EFCD)))),
        ],
      ),
    );
  }
}