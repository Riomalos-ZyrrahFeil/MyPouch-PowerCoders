import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_pin_keypad.dart';

class PINSetupScreen extends StatefulWidget {
  final bool isConfirmation;
  final Function(String pin) onPINSubmit;
  final VoidCallback onBack;
  final String? errorMessage;

  const PINSetupScreen({
    super.key,
    required this.isConfirmation,
    required this.onPINSubmit,
    required this.onBack,
    this.errorMessage,
  });

  @override
  State<PINSetupScreen> createState() => _PINSetupScreenState();
}

class _PINSetupScreenState extends State<PINSetupScreen> {
  String _pinEntry = '';
  final int _pinLength = 4;

  void _onDigitPressed(String digit) {
    if (_pinEntry.length < _pinLength) {
      setState(() {
        _pinEntry += digit;
      });

      // Auto-submit when PIN is complete
      if (_pinEntry.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onPINSubmit(_pinEntry);
        });
      }
    }
  }

  void _onBackspacePressed() {
    if (_pinEntry.isNotEmpty) {
      setState(() {
        _pinEntry = _pinEntry.substring(0, _pinEntry.length - 1);
      });
    }
  }

  void _clearPIN() {
    setState(() {
      _pinEntry = '';
    });
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pinEntry.length
                ? Colors.white
                : Colors.white30,
          ),
        );
      }),
    );
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Header
                  Text(
                    'Protect your Pouch.',
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
                    widget.isConfirmation
                        ? 'Confirm your PIN'
                        : 'Create a 4-digit PIN to keep your\nsavings private.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Dot Indicator
                  _buildDotIndicator(),
                  const SizedBox(height: 48),

                  // PIN Keypad
                  CustomPINKeypad(
                    onDigitPressed: _onDigitPressed,
                    onBackspacePressed: _onBackspacePressed,
                  ),

                  const SizedBox(height: 32),

                  // Confirm Button (enabled when PIN is complete)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _pinEntry.length == _pinLength
                          ? () {
                              widget.onPINSubmit(_pinEntry);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pinEntry.length == _pinLength
                            ? Colors.white
                            : Colors.white38,
                        foregroundColor: const Color(0xFF238E5F),
                        elevation:
                            _pinEntry.length == _pinLength ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.white38,
                      ),
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _pinEntry.length == _pinLength
                              ? const Color(0xFF238E5F)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error Message if PINs don't match
                  if (widget.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Clear Button
                  if (_pinEntry.isNotEmpty)
                    TextButton(
                      onPressed: _clearPIN,
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
