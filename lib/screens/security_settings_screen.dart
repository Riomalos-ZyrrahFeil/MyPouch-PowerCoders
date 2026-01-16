import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pin_reset_screen.dart'; 
import 'security_question_screen.dart'; 
import 'nuclear_option_screen.dart'; 
import '../services/database_helper.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Security", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // CHANGE PIN
            _buildTile(
              context,
              icon: Icons.lock_reset,
              title: "Reset PIN",
              subtitle: "Update your access code",
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => PinResetScreen(
                      onBack: () => Navigator.pop(context),
                      onPinEntered: (newPin) async {
                        // Logic to update the PIN
                        try {
                          await DatabaseHelper().updatePin(newPin);
                          if (context.mounted) {
                            Navigator.pop(context); // Close Reset Screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("PIN Updated Successfully!")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // UPDATE RECOVERY QUESTION
            _buildTile(
              context,
              icon: Icons.question_answer_outlined,
              title: "Update Recovery Question",
              subtitle: "Change your security question",
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => SecurityQuestionScreen(
                      onBack: () => Navigator.pop(context),
                      onSecuritySetup: (String question, String answer) async {
                        await DatabaseHelper().updateSecurityQuestion(question, answer);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Security Question Updated")),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            
            const Spacer(),
            
            // RESET APP (Nuclear Option)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text("Reset App", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                subtitle: Text("Wipe all data and start fresh", style: GoogleFonts.poppins(color: Colors.redAccent.withOpacity(0.7), fontSize: 12)),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => NuclearOptionScreen(
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF238E5F)),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}