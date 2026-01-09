import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'profile_setup_screen.dart';
import 'pin_setup_screen.dart';
import 'security_question_screen.dart';
import 'account_creation_success_screen.dart';
import 'pin_login_screen.dart';

class SetupFlowScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const SetupFlowScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends State<SetupFlowScreen> {
  int _currentStep = 0; // 0: Profile, 1: PIN Creation, 2: PIN Confirmation, 3: Security Question, 4: Success
  String? _nickname;
  String? _pinCreated;
  String? _securityQuestion;
  String? _securityAnswer;
  bool _isLoading = false;
  String? _errorMessage;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _goToNextStep() {
    setState(() {
      _currentStep++;
      _errorMessage = null;
    });
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleNicknameSubmit(String nickname) async {
    setState(() {
      _nickname = nickname;
    });
    _goToNextStep();
  }

  Future<void> _handlePINCreation(String pin) async {
    setState(() {
      _pinCreated = pin;
    });
    _goToNextStep();
  }

  Future<void> _handlePINConfirmation(String pin) async {
    if (pin != _pinCreated) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _currentStep = 1; // Go back to PIN creation
      });
      // Show dialog with option to retry
      _showErrorDialog(
        'PINs do not match',
        'The PIN you confirmed does not match your original PIN. Please try again.',
      );
    } else {
      _goToNextStep();
    }
  }

  Future<void> _handleSecuritySetup(
    String question,
    String answer,
  ) async {
    setState(() {
      _securityQuestion = question;
      _securityAnswer = answer;
      _isLoading = true;
    });

    try {
      // Save all user data to database
      await _dbHelper.saveUserProfile(
        nickname: _nickname!,
        pin: _pinCreated!,
        securityQuestion: _securityQuestion!,
        securityAnswer: _securityAnswer!,
      );

      setState(() {
        _isLoading = false;
      });

      // Go to success screen (step 4)
      _goToNextStep();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error saving profile: ${e.toString()}';
      });
      _showErrorDialog(
        'Error',
        'Failed to save your profile. Please try again.',
      );
    }
  }

  void _handleSuccessClose() {
    // Navigate to PIN Login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PINLoginScreen(),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Step 0: Profile Setup
        if (_currentStep == 0)
          ProfileSetupScreen(
            onNicknameSubmit: _handleNicknameSubmit,
          ),

        // Step 1: PIN Creation
        if (_currentStep == 1)
          PINSetupScreen(
            key: const ValueKey('pin_setup_creation'),
            isConfirmation: false,
            onPINSubmit: _handlePINCreation,
            onBack: _goToPreviousStep,
            errorMessage: _errorMessage,
          ),

        // Step 2: PIN Confirmation
        if (_currentStep == 2)
          PINSetupScreen(
            key: const ValueKey('pin_confirmation'),
            isConfirmation: true,
            onPINSubmit: _handlePINConfirmation,
            onBack: _goToPreviousStep,
            errorMessage: _errorMessage,
          ),

        // Step 3: Security Question
        if (_currentStep == 3)
          SecurityQuestionScreen(
            onSecuritySetup: _handleSecuritySetup,
            onBack: _goToPreviousStep,
          ),

        // Step 4: Account Creation Success
        if (_currentStep == 4)
          AccountCreationSuccessScreen(
            onOpenPouch: _handleSuccessClose,
          ),

        // Error message banner
        if (_errorMessage != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
