import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import 'money_source_screen.dart';

class AddSavingScreen extends StatefulWidget {
  const AddSavingScreen({super.key});

  @override
  State<AddSavingScreen> createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends State<AddSavingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Map<String, dynamic>> _displayGoals = [];
  int? _selectedGoalId; // If -1, it means "General Savings"
  String _selectedSource = "Cash";
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _dbHelper.getAllGoals();
    
    // Create a special item for "General Savings"
    final generalSavings = {
      'id': -1,
      'title': 'General Savings',
      'image_path': 'assets/logo.png',
      'is_general': true,
    };

    if (mounted) {
      setState(() {
        _displayGoals = [generalSavings, ...goals];
        _selectedGoalId = -1;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount and select a destination.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double amount = double.parse(_amountController.text.replaceAll(',', ''));
      int finalGoalId;

      if (_selectedGoalId == -1) {
        finalGoalId = await _dbHelper.getGeneralSavingsGoalId();
      } else {
        finalGoalId = _selectedGoalId!;
      }
      
      await _dbHelper.addContribution(
        goalId: finalGoalId,
        amount: amount,
        note: _noteController.text.isEmpty ? 'Deposit' : _noteController.text,
        source: _selectedSource,
      );

      if (!mounted) return;
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectSource() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const MoneySourceScreen())
    );
    if (result != null) {
      setState(() => _selectedSource = result);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF238E5F),
              onPrimary: Colors.white,
              surface: Color(0xFF01140E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add Savings", style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AMOUNT INPUT
            Center(
              child: Column(
                children: [
                  Text("Enter Amount", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: "₱ ",
                      prefixStyle: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontSize: 40, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      hintText: "0.00",
                      hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // SAVE TO (Horizontal List)
            Text("Save to", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120, 
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _displayGoals.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final goal = _displayGoals[index];
                  final isSelected = goal['id'] == _selectedGoalId;
                  final imagePath = goal['image_path'] ?? 'assets/logo.png';
                  
                  // Determine image provider
                  ImageProvider bgImage;
                  if (imagePath.startsWith('assets/')) {
                    bgImage = AssetImage(imagePath);
                  } else {
                    bgImage = FileImage(File(imagePath));
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedGoalId = goal['id']);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected 
                                ? Border.all(color: const Color(0xFF238E5F), width: 3) 
                                : Border.all(color: Colors.white10),
                            image: DecorationImage(
                              image: bgImage,
                              fit: BoxFit.cover,
                              colorFilter: isSelected 
                                  ? null 
                                  : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                            ),
                          ),
                          child: isSelected 
                              ? const Center(child: Icon(Icons.check, color: Colors.white, size: 30))
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            goal['title'],
                            style: GoogleFonts.poppins(
                              color: isSelected ? const Color(0xFF238E5F) : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // FROM (Source Selection)
            Text("From", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectSource,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF238E5F)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedSource,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DATE & NOTE
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF238E5F), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd').format(_selectedDate),
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Note", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Optional",
                          hintStyle: GoogleFonts.poppins(color: Colors.white30),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238E5F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Confirm Savings", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}