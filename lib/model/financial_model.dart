class FinancialModel {
  int? id;
  String? tipe;
  String? keterangan;
  String? jml_uang;
  String? tanggal;
  String? createdAt;
  double? latitude; // Tambahkan ini
  double? longitude; // Tambahkan ini

  FinancialModel({
    this.id,
    this.tipe,
    this.keterangan,
    this.jml_uang,
    this.tanggal,
    this.createdAt,
    this.latitude, // Tambahkan ini
    this.longitude, // Tambahkan ini
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'tipe': tipe,
      'keterangan': keterangan,
      'jml_uang': jml_uang,
      'tanggal': tanggal,
      'createdAt': createdAt,
      'latitude': latitude, // Tambahkan ini
      'longitude': longitude, // Tambahkan ini
    };
    return map;
  }

  FinancialModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    tipe = map['tipe'];
    keterangan = map['keterangan'];
    jml_uang = map['jml_uang'];
    tanggal = map['tanggal'];
    createdAt = map['createdAt'];
    latitude = map['latitude']; // Tambahkan ini
    longitude = map['longitude']; // Tambahkan ini
  }
}