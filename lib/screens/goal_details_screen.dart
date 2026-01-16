import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'celebration_screen.dart';
import 'add_saving_screen.dart';

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
  
  // State variables for dynamic values
  double _currentAmount = 0;
  double _targetAmount = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _dbHelper.getContributions(widget.goalId);
    final goalDetails = await _dbHelper.getGoalDetails(widget.goalId);
    
    if (goalDetails != null) {
      _currentAmount = (goalDetails['current_amount'] as num).toDouble();
      _targetAmount = (goalDetails['target_amount'] as num).toDouble();
      _progress = _targetAmount > 0 ? _currentAmount / _targetAmount : 0;
    }
    
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  void _addFunds() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSavingScreen()),
    );
    
    if (result == true && mounted) {
      await _loadHistory();
    }
  }

  void _showWithdrawalDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A2926),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Withdraw Funds",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  "Amount",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    hintStyle: GoogleFonts.poppins(color: Colors.white30),
                    prefixText: "₱ ",
                    prefixStyle: GoogleFonts.poppins(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Note (Optional)",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "e.g., Emergency expense",
                    hintStyle: GoogleFonts.poppins(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Enter a valid amount", style: GoogleFonts.poppins(color: Colors.white)),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // Record withdrawal as negative amount
                          await _dbHelper.addContribution(
                            goalId: widget.goalId,
                            amount: -amount,
                            note: noteController.text.isEmpty ? "Withdrawal" : noteController.text,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            await _loadHistory();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("₱${amount.toStringAsFixed(2)} withdrawn successfully", style: GoogleFonts.poppins(color: Colors.white)),
                                backgroundColor: const Color(0xFF238E5F),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "Withdraw",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Saved", style: GoogleFonts.poppins(color: Colors.white70)), Text("₱${_currentAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Target", style: GoogleFonts.poppins(color: Colors.white70)), Text("₱${_targetAmount.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: _progress, minHeight: 12, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF238E5F)))),
                  const SizedBox(height: 8),
                  Text("${(_progress * 100).toInt()}% Achieved", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addFunds,
                          icon: const Icon(Icons.add),
                          label: Text("Add Funds", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF238E5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showWithdrawalDialog,
                          icon: const Icon(Icons.remove),
                          label: Text("Withdraw", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
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