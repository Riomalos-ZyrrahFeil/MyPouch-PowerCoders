import 'package:flutter/material.dart';
import 'account_recovery_screen.dart';
import 'nuclear_option_screen.dart';
import 'pin_reset_screen.dart';
import 'pin_confirmation_screen.dart';
import 'pin_reset_success_screen.dart';
import '../services/database_helper.dart';

class AccountRecoveryFlow extends StatefulWidget {
  final VoidCallback onRecoveryComplete;

  const AccountRecoveryFlow({
    super.key,
    required this.onRecoveryComplete,
  });

  @override
  State<AccountRecoveryFlow> createState() => _AccountRecoveryFlowState();
}

class _AccountRecoveryFlowState extends State<AccountRecoveryFlow> {
  int _currentStep = 0; // 0: Recovery, 1: Nuclear, 2: Reset, 3: Confirm, 4: Success
  String _newPin = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _handleAnswerSubmit(bool isVerified) {
    if (isVerified) {
      setState(() {
        _currentStep = 2; // Move to PIN Reset
      });
    }
  }

  void _handleForgotSecurityQuestion() {
    setState(() {
      _currentStep = 1; // Move to Nuclear Option
    });
  }

  void _handlePinEntered(String pin) {
    setState(() {
      _newPin = pin;
      _currentStep = 3; // Move to PIN Confirmation
    });
  }

  Future<void> _handlePinConfirmed(bool isMatching) async {
    if (isMatching) {
      try {
        // Update PIN in database
        await _dbHelper.updatePin(_newPin);

        setState(() {
          _currentStep = 4; // Move to Success
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating PIN: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _currentStep = 2; // Go back to PIN Reset
          });
        }
      }
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        if (_currentStep == 1) {
          _newPin = '';
        }
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: _currentStep == 0
          ? AccountRecoveryScreen(
              onAnswerSubmit: _handleAnswerSubmit,
              onBack: _handleBack,
              onForgotSecurityQuestion: _handleForgotSecurityQuestion,
            )
          : _currentStep == 1
              ? NuclearOptionScreen(
                  onBack: _handleBack,
                )
              : _currentStep == 2
                  ? PinResetScreen(
                      onPinEntered: _handlePinEntered,
                      onBack: _handleBack,
                    )
                  : _currentStep == 3
                      ? PinConfirmationScreen(
                          firstPin: _newPin,
                          onPinConfirmed: _handlePinConfirmed,
                          onBack: _handleBack,
                        )
                      : PinResetSuccessScreen(
                          onReturnToLogin: () {
                            widget.onRecoveryComplete();
                            Navigator.of(context).pop();
                          },
                        ),
    );
  }
}
