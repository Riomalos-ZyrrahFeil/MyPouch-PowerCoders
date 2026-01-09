import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../widgets/custom_pin_keypad.dart';
import 'account_recovery_flow.dart';
import 'home_screen.dart';

class PINLoginScreen extends StatefulWidget {
  const PINLoginScreen({super.key});

  @override
  State<PINLoginScreen> createState() => _PINLoginScreenState();
}

class _PINLoginScreenState extends State<PINLoginScreen> {
  String _pinEntry = '';
  final int _pinLength = 4;
  String? _errorMessage;
  bool _isLoading = false;
  int _attemptCount = 0;
  final int _maxAttempts = 3;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _onDigitPressed(String digit) {
    if (_pinEntry.length < _pinLength) {
      setState(() {
        _pinEntry += digit;
        _errorMessage = null;
      });

      // Auto-verify when PIN is complete
      if (_pinEntry.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _verifyPIN();
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

  void _clearPIN() {
    setState(() {
      _pinEntry = '';
      _errorMessage = null;
    });
  }

  Future<void> _verifyPIN() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('=== PIN LOGIN ATTEMPT ===');
      debugPrint('Entered PIN: $_pinEntry (length: ${_pinEntry.length})');
      debugPrint('Attempt: $_attemptCount / $_maxAttempts');
      
      final isValid = await _dbHelper.verifyPin(_pinEntry);

      if (isValid) {
        // Success - navigate to home
        debugPrint('✓ PIN verification successful');
        
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        // Navigate to home screen directly
        if (mounted) {
          debugPrint('About to navigate to HomeScreen...');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
          debugPrint('Navigation complete');
        } else {
          debugPrint('Widget not mounted, cannot navigate');
        }
      } else {
        // Wrong PIN
        debugPrint('✗ PIN verification failed');
        _attemptCount++;
        
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
          _pinEntry = '';
          
          if (_attemptCount >= _maxAttempts) {
            _errorMessage = 'Too many failed attempts. Please try again later.';
          } else {
            final remaining = _maxAttempts - _attemptCount;
            _errorMessage = 'Incorrect PIN. $remaining attempts remaining.';
          }
        });

        if (_attemptCount >= _maxAttempts) {
          _showLockedDialog();
        }
      }
    } catch (e) {
      debugPrint('✗ Error in PIN verification: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error verifying PIN. Please try again.';
        _pinEntry = '';
      });
    }
  }

  void _navigateToRecovery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountRecoveryFlow(
          onRecoveryComplete: () {
            // Reset attempt counter after successful recovery
            setState(() {
              _attemptCount = 0;
              _pinEntry = '';
              _errorMessage = null;
            });
          },
        ),
      ),
    );
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF01140E),
        title: Text(
          'Account Locked',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Too many failed attempts. Please use the security question to recover your account.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRecovery();
            },
            child: Text(
              'Recover Account',
              style: GoogleFonts.poppins(
                color: const Color(0xFF238E5F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
                  'Welcome Back!',
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
                  'Enter your PIN to access your savings',
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

                // PIN Keypad
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : CustomPINKeypad(
                          onDigitPressed: _onDigitPressed,
                          onBackspacePressed: _onBackspacePressed,
                        ),
                ),

                const SizedBox(height: 32),

                // Clear Button
                if (_pinEntry.isNotEmpty && !_isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _clearPIN,
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                // Forgot PIN Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _attemptCount < _maxAttempts
                        ? _navigateToRecovery
                        : null,
                    child: Text(
                      'Forgot PIN?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _attemptCount < _maxAttempts
                            ? const Color(0xFF238E5F)
                            : Colors.white38,
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
