import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSetupScreen extends StatefulWidget {
  final Function(String nickname) onNicknameSubmit;

  const ProfileSetupScreen({
    super.key,
    required this.onNicknameSubmit,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nicknameController.text.trim().isNotEmpty;
    });
  }

  void _handleNext() {
    if (_isButtonEnabled) {
      widget.onNicknameSubmit(_nicknameController.text.trim());
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

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
              Color(0xFF015940), // Top Green
              Color(0xFF01140E), // Bottom Dark/Black
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Text(
                  "Let's get to know you.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  "What should we call you?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Nickname Input Field
                TextField(
                  controller: _nicknameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Nickname',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1a4d3a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF238E5F),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF238E5F),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF238E5F),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _handleNext(),
                ),
                const SizedBox(height: 48),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled
                          ? Colors.white
                          : Colors.white38,
                      foregroundColor: const Color(0xFF238E5F),
                      elevation: _isButtonEnabled ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.white38,
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
