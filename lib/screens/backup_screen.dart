import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("Backup & Restore", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Export Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF238E5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF238E5F)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, color: Color(0xFF238E5F), size: 40),
                  const SizedBox(height: 16),
                  Text("Export Data", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    "Save a copy of your goals and transaction history to your device.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement CSV/JSON Export Logic
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data exported to Downloads folder")));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238E5F)),
                      child: Text("Export Now", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Restore Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Icon(Icons.download_for_offline, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  Text("Restore Data", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    "Import a previously saved backup file to restore your progress.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement File Picker & Import Logic
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      child: Text("Select File", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}