import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';

class AccountRecoveryScreen extends StatefulWidget {
  final Function(bool isVerified) onAnswerSubmit;
  final VoidCallback onBack;
  final VoidCallback onForgotSecurityQuestion;

  const AccountRecoveryScreen({
    super.key,
    required this.onAnswerSubmit,
    required this.onBack,
    required this.onForgotSecurityQuestion,
  });

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _securityQuestion;
  bool _isButtonEnabled = false;
  bool _isLoading = true;
  String? _errorMessage;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
    _answerController.addListener(_updateButtonState);
  }

  Future<void> _loadSecurityQuestion() async {
    try {
      final question = await _dbHelper.getSecurityQuestion();
      setState(() {
        _securityQuestion = question;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading security question';
        _isLoading = false;
      });
    }
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _answerController.text.trim().isNotEmpty;
    });
  }

  Future<void> _verifyAnswer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isCorrect = await _dbHelper.verifySecurityAnswer(
        _answerController.text.trim(),
      );

      if (!mounted) return;

      if (isCorrect) {
        widget.onAnswerSubmit(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect answer. Please try again.';
          _answerController.clear();
          _isButtonEnabled = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error verifying answer. Please try again.';
      });
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
            child: _isLoading && _securityQuestion == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 32),

                      // Header
                      Text(
                        'Account Recovery',
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
                        'Answer your security question to reset your PIN',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Security Question Display
                      if (_securityQuestion != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a4d3a),
                            border: Border.all(
                              color: const Color(0xFF238E5F),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _securityQuestion!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ),

                      if (_errorMessage != null) const SizedBox(height: 24),

                      // Answer Input Field
                      TextField(
                        controller: _answerController,
                        textAlign: TextAlign.center,
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
                        onSubmitted: (_) {
                          if (_isButtonEnabled) {
                            _verifyAnswer();
                          }
                        },
                      ),

                      const Spacer(),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled && !_isLoading
                              ? _verifyAnswer
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isButtonEnabled && !_isLoading
                                ? Colors.white
                                : Colors.white38,
                            foregroundColor: const Color(0xFF238E5F),
                            elevation:
                                _isButtonEnabled && !_isLoading ? 4 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.white38,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Color(0xFF238E5F),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Verify',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // I forgot this too button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: widget.onForgotSecurityQuestion,
                          child: Text(
                            'I forgot this too',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
