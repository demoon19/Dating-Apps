import 'package:flutter/material.dart';
import '../database/DatabaseHelper.dart';
import '../model/financial_model.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import '../services/notification_service.dart';

class PageInputExpense extends StatefulWidget {
  final FinancialModel? financialModel;

  const PageInputExpense({Key? key, this.financialModel}) : super(key: key);

  @override
  _PageInputExpenseState createState() => _PageInputExpenseState();
}

class _PageInputExpenseState extends State<PageInputExpense> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController? keterangan;
  TextEditingController? tanggal;
  TextEditingController? jml_uang;
  LocationData? _locationData;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    keterangan =
        TextEditingController(text: widget.financialModel?.keterangan ?? '');
    tanggal = TextEditingController(text: widget.financialModel?.tanggal ?? '');
    jml_uang =
        TextEditingController(text: widget.financialModel?.jml_uang ?? '');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _isGettingLocation = false;
    });
  }

  Future<void> upsertData() async {
    if (widget.financialModel != null) {
      //update
      await databaseHelper.updateData(
          FinancialModel(
            id: widget.financialModel!.id,
            tipe: 'pengeluaran',
            keterangan: keterangan!.text,
            jml_uang: jml_uang!.text,
            tanggal: tanggal!.text,
            createdAt: widget.financialModel!.createdAt,
            latitude: _locationData?.latitude,
            longitude: _locationData?.longitude,
          ),
          "pengeluaran");

      // Notifikasi untuk update
      NotificationService.showNotification(
          id: widget.financialModel!.id!,
          title: "Catatan Diperbarui",
          body: "Pengeluaran '${keterangan!.text}' telah diperbarui.");

      if (!mounted) return;
      Navigator.pop(context, 'update');
    } else {
      //insert
      await databaseHelper.saveData(FinancialModel(
        tipe: 'pengeluaran',
        keterangan: keterangan!.text,
        jml_uang: jml_uang!.text,
        tanggal: tanggal!.text,
        createdAt: DateTime.now().toIso8601String(),
        latitude: _locationData?.latitude,
        longitude: _locationData?.longitude,
      ));

      // Notifikasi untuk insert
      NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Catatan Ditambahkan",
          body: "Pengeluaran baru '${keterangan!.text}' berhasil disimpan.");

      if (!mounted) return;
      Navigator.pop(context, 'save');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFFa7a597),
        title: const Text('Form Data Pengeluaran',
            style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            controller: keterangan,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
                labelText: 'Keterangan',
                labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                              onPrimary: Colors.white,
                              onBackground: Colors.white),
                          datePickerTheme: const DatePickerThemeData(
                            backgroundColor: Color.fromARGB(255, 197, 197, 197),
                            headerBackgroundColor: Color(0xFFa7a597),
                            headerForegroundColor: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(9999));
                if (pickedDate != null) {
                  tanggal!.text =
                      DateFormat('dd MMM yyyy').format(pickedDate);
                }
              },
              controller: tanggal,
              decoration: InputDecoration(
                  labelText: 'Tanggal',
                  labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              controller: jml_uang,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  labelText: 'Jumlah Uang',
                  labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
            ),
          ),
          if (_isGettingLocation)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_locationData != null)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Lokasi Telah Tercatat',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Gagal mendapatkan lokasi. Pastikan GPS aktif.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFa7a597)),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (keterangan!.text.isEmpty ||
                          tanggal!.text.isEmpty ||
                          jml_uang!.text.isEmpty) {
                        const snackBar = SnackBar(
                            content: Text("Ups, form tidak boleh ada yang kosong!"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        upsertData();
                      }
                    },
                    child: Center(
                      child: (widget.financialModel == null)
                          ? const Text('Tambah Data',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white))
                          : const Text('Update Data',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}