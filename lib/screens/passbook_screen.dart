import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../theme.dart';

class PassbookScreen extends StatefulWidget {
  final int refreshTrigger;

  const PassbookScreen({
    super.key,
    this.refreshTrigger = 0,
  });

  @override
  State<PassbookScreen> createState() => _PassbookScreenState();
}

class _PassbookScreenState extends State<PassbookScreen> {
  // State for the custom filter tabs (0: All, 1: Deposits, 2: Withdrawals)
  int _selectedFilterIndex = 0;

  late Future<List<Map<String, dynamic>>> _transactionsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Formatters
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Reload data when Dashboard triggers an update
  @override
  void didUpdateWidget(covariant PassbookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _loadTransactions();
    }
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _dbHelper.getAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Labels for our custom tabs
    final List<String> filterLabels = ["All", "Deposits", "Withdrawals"];

    return Scaffold(
      backgroundColor: const Color(0xFF01140E), // Match Statistics background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER (Left Aligned) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                  "Passbook",
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  )
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. CUSTOM FILTER BUTTONS (Like Statistics) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: filterLabels.asMap().entries.map((entry) {
                    bool isSelected = _selectedFilterIndex == entry.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF238E5F) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- 3. TRANSACTION LIST ---
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF238E5F)));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading data", style: GoogleFonts.poppins(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text("No transactions yet", style: GoogleFonts.poppins(color: Colors.white54)),
                        ],
                      ),
                    );
                  }

                  // Filter the data based on the selected button
                  List<Map<String, dynamic>> filteredList = snapshot.data!;
                  if (_selectedFilterIndex == 1) {
                    // Deposits only
                    filteredList = filteredList.where((t) => (t['amount'] as num) > 0).toList();
                  } else if (_selectedFilterIndex == 2) {
                    // Withdrawals only
                    filteredList = filteredList.where((t) => (t['amount'] as num) < 0).toList();
                  }

                  if (filteredList.isEmpty) {
                    return Center(child: Text("No records in this category", style: GoogleFonts.poppins(color: Colors.white24)));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final transaction = filteredList[index];
                      _buildTransactionItem(transaction);

                      return _buildTransactionItem(transaction);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final double amount = (transaction['amount'] as num).toDouble();
    final bool isDeposit = amount >= 0;
    final DateTime date = DateTime.parse(transaction['created_at']);
    final String title = transaction['goal_title'] ?? 'Unknown Goal';
    final String? note = transaction['note'];
    final String? imagePath = transaction['image_path'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // --- GOAL IMAGE ---
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white10,
              image: (imagePath != null && imagePath.isNotEmpty)
                  ? DecorationImage(
                image: imagePath.startsWith('assets/')
                    ? AssetImage(imagePath) as ImageProvider
                    : FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: (imagePath == null || imagePath.isEmpty)
                ? Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeposit ? Colors.green : Colors.red,
            )
                : null,
          ),
          const SizedBox(width: 16),

          // --- DETAILS ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _dateFormat.format(date),
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                if (note != null && note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      note,
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // --- AMOUNT ---
          Text(
            "${isDeposit ? '+' : ''}${_currencyFormat.format(amount)}",
            style: GoogleFonts.poppins(
              color: isDeposit ? AppTheme.primaryGreen : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}