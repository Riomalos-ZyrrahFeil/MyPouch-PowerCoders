import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountCreationSuccessScreen extends StatelessWidget {
  final VoidCallback onOpenPouch;

  const AccountCreationSuccessScreen({
    super.key,
    required this.onOpenPouch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF015940),
              Color(0xFF01140E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon/Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF238E5F).withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFF238E5F),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Color(0xFF238E5F),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Success Title
              Text(
                'Account Created!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Your MyPouch account is all set. You\'re ready to start saving and achieving your financial goals!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 56),

              // Open My Pouch Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onOpenPouch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF238E5F),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Open My Pouch',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
