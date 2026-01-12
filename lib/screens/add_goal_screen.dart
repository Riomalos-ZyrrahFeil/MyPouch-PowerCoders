import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/database_helper.dart';

class AddGoalScreen extends StatefulWidget {
  final Map<String, dynamic>? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  
  File? _selectedImage;
  String? _currentImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing
    if (widget.goal != null) {
      _titleController.text = widget.goal!['title'];
      _targetAmountController.text = widget.goal!['target_amount'].toString();
      _currentImagePath = widget.goal!['image_path'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty || _targetAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imagePath = _currentImagePath ?? 'assets/walkthrough.jpg';
      // If user picked a NEW image, save it
      if (_selectedImage != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_selectedImage!.path);
        final savedImage = await _selectedImage!.copy('${appDir.path}/$fileName');
        imagePath = savedImage.path;
      }

      if (widget.goal != null) {
        // UPDATE Existing Goal
        await _dbHelper.updateGoal(
          id: widget.goal!['id'],
          title: _titleController.text,
          targetAmount: double.parse(_targetAmountController.text),
          imagePath: imagePath,
        );
      } else {
        // CREATE New Goal
        await _dbHelper.addGoal(
          title: _titleController.text,
          description: '', 
          targetAmount: double.parse(_targetAmountController.text),
          imagePath: imagePath,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine Image Provider for display
    ImageProvider? bgImage;
    if (_selectedImage != null) {
      bgImage = FileImage(_selectedImage!);
    } else if (_currentImagePath != null) {
      if (_currentImagePath!.startsWith('assets/')) {
        bgImage = AssetImage(_currentImagePath!);
      } else {
        bgImage = FileImage(File(_currentImagePath!));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.goal != null ? "Edit Goal" : "Add New Goal", 
          style: GoogleFonts.poppins(color: Colors.white)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                    image: bgImage != null
                        ? DecorationImage(image: bgImage, fit: BoxFit.cover)
                        : null,
                  ),
                  child: bgImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo, color: Colors.white54, size: 40),
                            const SizedBox(height: 10),
                            Text("Add Reference Image", style: GoogleFonts.poppins(color: Colors.white54)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              
              Text("Goal Name", style: GoogleFonts.poppins(color: Colors.white70)),
              const SizedBox(height: 8),
              _buildTextField("e.g. New Laptop", _titleController, false),
              
              const SizedBox(height: 20),
              
              Text("Target Amount", style: GoogleFonts.poppins(color: Colors.white70)),
              const SizedBox(height: 8),
              _buildTextField("e.g. 50000", _targetAmountController, true),
        
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238E5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.goal != null ? "Update Goal" : "Create Goal",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isNumber) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}             