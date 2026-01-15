import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pin_reset_screen.dart'; // Reuse existing screens if possible

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("Security", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTile(
              context,
              icon: Icons.lock_reset,
              title: "Change PIN",
              onTap: () {
                // Navigate to PIN Reset Flow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinResetScreen(
                      onPinEntered: (pin) {
                        Navigator.pop(context);
                      },
                      onBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTile(
              context,
              icon: Icons.question_answer_outlined,
              title: "Update Recovery Question",
              onTap: () {
                // Implement Update Recovery Screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature coming soon")));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF238E5F)),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}