import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'celebration_screen.dart';

class GoalDetailsScreen extends StatefulWidget {
  final int goalId;
  final String title;
  final String savedAmount;
  final String targetAmount;
  final double progress;
  final String imagePath;

  const GoalDetailsScreen({
    super.key,
    required this.goalId,
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.progress,
    required this.imagePath,
  });

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _dbHelper.getContributions(widget.goalId);
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  void _addFunds() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider bgImage;
    if (widget.imagePath.startsWith('assets/')) {
      bgImage = AssetImage(widget.imagePath);
    } else {
      bgImage = FileImage(File(widget.imagePath));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: const Color(0xFF01140E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Image(
                image: bgImage,
                fit: BoxFit.cover,
                color: Colors.black45,
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Saved", style: GoogleFonts.poppins(color: Colors.white70)), Text(widget.savedAmount, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Target", style: GoogleFonts.poppins(color: Colors.white70)), Text(widget.targetAmount, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: widget.progress, minHeight: 12, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF238E5F)))),
                  const SizedBox(height: 8),
                  Text("${(widget.progress * 100).toInt()}% Achieved", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Goal Transactions", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),

          // TRANSACTIONS LIST
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _transactions[index];
              final double amount = (item['amount'] as num).toDouble();
              final bool isWithdrawal = amount < 0;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    isWithdrawal ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isWithdrawal ? Colors.redAccent : const Color(0xFF238E5F)
                  )
                ),
                title: Text(
                  item['note'] ?? (isWithdrawal ? "Withdrawal" : "Deposit"),
                  style: GoogleFonts.poppins(color: Colors.white)
                ),
                subtitle: Text(
                  item['created_at'].toString().split(' ')[0],
                  style: GoogleFonts.poppins(color: Colors.white54)
                ),
                trailing: Text(
                  "${isWithdrawal ? '' : '+'}₱${amount.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    color: isWithdrawal ? Colors.redAccent : const Color(0xFF238E5F),
                    fontWeight: FontWeight.bold
                  )
                ),
              );
            }, childCount: _transactions.length),
          ),
        ],
      ),
    );
  }
}