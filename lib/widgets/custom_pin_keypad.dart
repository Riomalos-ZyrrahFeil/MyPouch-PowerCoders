import 'package:flutter/material.dart';

class CustomPINKeypad extends StatelessWidget {
  final Function(String digit) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomPINKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 24),
        
        // Row 2: 4, 5, 6
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 24),
        
        // Row 3: 7, 8, 9
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 24),
        
        // Row 4: 0, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildKeypadButton(
                text: '0',
                onPressed: () => onDigitPressed('0'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildKeypadButton(
                isBackspace: true,
                onPressed: onBackspacePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits
          .map(
            (digit) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildKeypadButton(
                text: digit,
                onPressed: () => onDigitPressed(digit),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKeypadButton({
    String? text,
    bool isBackspace = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1a4d3a),
          border: Border.all(
            color: const Color(0xFF238E5F),
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: isBackspace
                  ? Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 28,
                    )
                  : Text(
                      text ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
