import 'package:flutter/material.dart';
import '../../database/DatabaseHelper.dart';
import '../../model/financial_model.dart';
import '../views/page_input_income.dart';
import '../views/page_input_expense.dart';
import '../views/page_detail_note.dart';
import '../controllers/other_controllers.dart';

class NoteController {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final OtherController otherController = OtherController();

  Future<void> getTransactions(List<FinancialModel> listTransactions,
      Function(int) updateTotalIncome, Function(int) updateTotalExpense) async {
    var allData = await databaseHelper.getAllDataTransaction();

    // Menghapus data transaksi yang ada dan menambahkan data baru dari database
    listTransactions.clear();
    listTransactions.addAll(
        allData!.map((data) => FinancialModel.fromMap(data)));

    // Mengurutkan transaksi berdasarkan createdAt secara menurun
    listTransactions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    // Menghitung total pendapatan dan pengeluaran
    final totalIncome = calculateTotalIncome(listTransactions);
    final totalExpense = calculateTotalExpense(listTransactions);

    // Memperbarui total pendapatan dan pengeluaran
    updateTotalIncome(totalIncome);
    updateTotalExpense(totalExpense);
}


  int calculateTotalIncome(List<FinancialModel> transactions) {
    // Menghitung total pendapatan dari daftar transaksi
    return transactions
        .where((transaction) =>
            transaction.tipe ==
            'pemasukan') // Memfilter transaksi berdasarkan tipe 'pemasukan'
        .map((transaction) => int.parse(
            transaction.jml_uang!)) // Mengambil jumlah uang dari transaksi
        .fold(
            0,
            (sum, amount) =>
                sum + amount); // Menjumlahkan jumlah uang dari semua transaksi
  }

  int calculateTotalExpense(List<FinancialModel> transactions) {
    // Menghitung total pengeluaran dari daftar transaksi
    return transactions
        .where((transaction) =>
            transaction.tipe ==
            'pengeluaran') // Memfilter transaksi berdasarkan tipe 'pengeluaran'
        .map((transaction) => int.parse(
            transaction.jml_uang!)) // Mengambil jumlah uang dari transaksi
        .fold(
            0,
            (sum, amount) =>
                sum + amount); // Menjumlahkan jumlah uang dari semua transaksi
  }

  int calculateBalance(int totalIncome, int totalExpense) {
    // Menghitung saldo yang tersisa
    return totalIncome - totalExpense; // Selisih antara total pendapatan dan total pengeluaran
  }


  Future<void> navigateToDetail(BuildContext context,
      FinancialModel financialModel, Function updateTransactions) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailNote(financialModel: financialModel),
      ),
    );

    // Jika ada pembaruan data, perbarui daftar transaksi
    updateTransactions();
  }

  Future<void> navigateToAddPemasukan(
      BuildContext context, Function updateTransactions) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInputIncome(),
      ),
    );

    if (result == 'save') {

    }

    // Setelah menambahkan transaksi, perbarui daftar transaksi
    updateTransactions();
  }

  Future<void> navigateToAddPengeluaran(
      BuildContext context, Function updateTransactions) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInputExpense(),
      ),
    );

    // Setelah menambahkan transaksi, perbarui daftar transaksi
    updateTransactions();
  }

  String formatAmount(double amount) {
    if (amount < (-1000000000)) {
      // Jika jumlah uang kurang dari -1 miliar, kembalikan 'Susah Hidup'
      return 'Susah Hidup';
    } else if (amount < 1000000) {
      // Jika jumlah uang kurang dari 1 juta, gunakan fungsi convertToIdr untuk mengonversinya ke format rupiah
      return OtherController.convertToIdr(amount);
    } else if (amount < 1000000000) {
      // Jika jumlah uang berada di antara 1 juta dan 1 miliar, bagi dengan 1 juta dan tambahkan 'Jt' di belakangnya
      double result = amount / 1000000;
      return OtherController.convertToIdr(result) + ' Jt';
    } else if (amount < 1000000000000) {
      // Jika jumlah uang berada di antara 1 miliar dan 1 triliun, bagi dengan 1 miliar dan tambahkan 'M' di belakangnya
      double result = amount / 1000000000;
      return OtherController.convertToIdr(result) + ' M';
    } else {
      // Jika jumlah uang lebih dari 1 triliun, bagi dengan 1 triliun dan tambahkan 'KB' di belakangnya
      double result = amount / 1000000000000;
      return OtherController.convertToIdr(result) + ' KB';
    }
  }

  void showOptions(BuildContext context, Function updateTransactions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Color(0xFF424242), // Background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF4EFC2), // Box shadow color
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(modalContext); // Gunakan modalContext di sini
                  navigateToAddPemasukan(context, updateTransactions);
                },
                child: Text(
                  'Input Pemasukan',
                  style: TextStyle(color: Color(0xFFF2EFCD)), // Text color
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(modalContext); // Gunakan modalContext di sini
                  navigateToAddPengeluaran(context, updateTransactions);
                },
                child: Text(
                  'Input Pengeluaran',
                  style: TextStyle(color: Color(0xFFF2EFCD)), // Text color
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
