import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityQuestionScreen extends StatefulWidget {
  final Function(String question, String answer) onSecuritySetup;
  final VoidCallback onBack;

  const SecurityQuestionScreen({
    super.key,
    required this.onSecuritySetup,
    required this.onBack,
  });

  @override
  State<SecurityQuestionScreen> createState() => _SecurityQuestionScreenState();
}

class _SecurityQuestionScreenState extends State<SecurityQuestionScreen> {
  static const List<String> _securityQuestions = [
    'What is your favorite color?',
    'What is the name of your favorite pet?',
    'What city were you born in?',
    'What is your mother\'s maiden name?',
    'What was the name of your first school?',
    'What is your favorite book?',
    'What is your favorite food?',
    'In case you forget...',
  ];

  String? _selectedQuestion;
  final TextEditingController _answerController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_updateFormValidity);
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _selectedQuestion != null &&
          _answerController.text.trim().isNotEmpty;
    });
  }

  void _handleFinishSetup() {
    if (_isFormValid) {
      widget.onSecuritySetup(
        _selectedQuestion!,
        _answerController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Header
                Text(
                  'In case you forget...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Set a security question so you can recover your account if needed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Security Question Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a4d3a),
                    border: Border.all(
                      color: const Color(0xFF238E5F),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedQuestion,
                      hint: Text(
                        'Select Question',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white38,
                        ),
                      ),
                      dropdownColor: const Color(0xFF1a4d3a),
                      underline: const SizedBox(),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      items: _securityQuestions
                          .map((question) => DropdownMenuItem(
                                value: question,
                                child: Text(question),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedQuestion = value;
                          _updateFormValidity();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Answer Input Field
                TextField(
                  controller: _answerController,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Answer...',
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
                ),
                const SizedBox(height: 48),

                // Finish Setup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _handleFinishSetup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid
                          ? Colors.white
                          : Colors.white38,
                      foregroundColor: const Color(0xFF238E5F),
                      elevation: _isFormValid ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.white38,
                    ),
                    child: Text(
                      'Finish Setup',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
