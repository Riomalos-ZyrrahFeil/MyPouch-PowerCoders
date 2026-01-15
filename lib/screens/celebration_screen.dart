import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';

class CelebrationScreen extends StatefulWidget {
  final int goalId;
  final String goalTitle;
  final double savedAmount;

  const CelebrationScreen({
    super.key,
    required this.goalId,
    required this.goalTitle,
    required this.savedAmount,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  bool _isWithdrawing = false;

  Future<void> _handleWithdraw() async {
    setState(() => _isWithdrawing = true);

    await DatabaseHelper().withdrawFunds(widget.goalId, widget.savedAmount);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Funds withdrawn for ${widget.goalTitle}! Enjoy!"),
        backgroundColor: const Color(0xFF238E5F),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF015940), Color(0xFF01140E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/success.png', height: 200, fit: BoxFit.contain),
              const SizedBox(height: 40),
              Text(
                "Pouch Filled!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, height: 1.5),
                  children: [
                    const TextSpan(text: "You crushed it! You've officially saved "),
                    TextSpan(text: "₱${widget.savedAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF238E5F))),
                    const TextSpan(text: " for your "),
                    TextSpan(text: widget.goalTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const TextSpan(text: " goal."),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text("All that discipline paid off. It's time to reward yourself.", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
              const Spacer(),

              // WITHDRAW BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isWithdrawing ? null : _handleWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF238E5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: _isWithdrawing
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text("Withdraw & Enjoy", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // CANCEL BUTTON
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Keep in Pouch", style: GoogleFonts.poppins(color: Colors.white54)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}