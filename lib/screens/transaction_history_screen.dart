import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool isGlobal;
  final String title;
  final String amount;

  const TransactionHistoryScreen({
    super.key,
    this.isGlobal = false,
    this.title = "History",
    this.amount = ""
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  Future<void> _loadAllHistory() async {
    if (widget.isGlobal) {
      final data = await _dbHelper.getAllTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.title, style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _transactions.isEmpty && widget.isGlobal
          ? Center(child: Text("No transaction history yet.", style: GoogleFonts.poppins(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.isGlobal ? _transactions.length : 1,
              itemBuilder: (context, index) {
                final double amount = (widget.isGlobal ? _transactions[index]['amount'] : 0.0) as double;
                final bool isWithdrawal = amount < 0;
                final String goalTitle = widget.isGlobal ? _transactions[index]['goal_title'] : "";
                final String note = widget.isGlobal ? (_transactions[index]['note'] ?? "") : "";

                String label;
                if (isWithdrawal) {
                  label = "Withdrawal from $goalTitle";
                } else {
                  label = "Deposit to $goalTitle";
                }

                if (note.isNotEmpty && note.length < 30) label = note;


                String date = widget.isGlobal ? _transactions[index]['created_at'].toString().split(' ')[0] : "Today";
                String val = widget.isGlobal
                    ? "${isWithdrawal ? '' : '+'}₱${amount.toStringAsFixed(0)}"
                    : widget.amount;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          isWithdrawal ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isWithdrawal ? Colors.redAccent : const Color(0xFF238E5F)
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                            Text(date, style: GoogleFonts.poppins(color: Colors.white54))
                          ]
                        )
                      ),
                      Text(
                        val,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isWithdrawal ? Colors.redAccent : const Color(0xFF238E5F)
                        )
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}