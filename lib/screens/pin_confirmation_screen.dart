import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_pin_keypad.dart';

class PinConfirmationScreen extends StatefulWidget {
  final String firstPin;
  final Function(bool isMatching) onPinConfirmed;
  final VoidCallback onBack;

  const PinConfirmationScreen({
    super.key,
    required this.firstPin,
    required this.onPinConfirmed,
    required this.onBack,
  });

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> {
  String _pinEntry = '';
  final int _maxPinLength = 4;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_pinEntry.length < _maxPinLength) {
      setState(() {
        _pinEntry += digit;
        _errorMessage = null;
      });

      // Auto-validate when PIN is complete
      if (_pinEntry.length == _maxPinLength) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _validatePin();
          }
        });
      }
    }
  }

  void _onBackspacePressed() {
    if (_pinEntry.isNotEmpty) {
      setState(() {
        _pinEntry = _pinEntry.substring(0, _pinEntry.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _clearPin() {
    setState(() {
      _pinEntry = '';
      _errorMessage = null;
    });
  }

  void _validatePin() {
    if (_pinEntry == widget.firstPin) {
      // PINs match - proceed to success screen
      widget.onPinConfirmed(true);
    } else {
      // PINs don't match - show error and clear
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _pinEntry = '';
      });
    }
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _maxPinLength,
        (index) => Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            color: index < _pinEntry.length ? Colors.white : Colors.transparent,
          ),
        ),
      ),
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
                    'Confirm PIN',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Re-enter your PIN to confirm',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // PIN Dot Indicator
                  _buildDotIndicator(),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 40),

                  // Custom PIN Keypad
                  CustomPINKeypad(
                    onDigitPressed: _onDigitPressed,
                    onBackspacePressed: _onBackspacePressed,
                  ),

                  const SizedBox(height: 32),

                  // Clear Button
                  if (_pinEntry.isNotEmpty)
                    TextButton(
                      onPressed: _clearPin,
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
