import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = await _dbHelper.getUserProfile();
    if (user != null) {
      _nameController.text = user['nickname'];
    }
  }

  Future<void> _saveProfile() async {
    // You'll need to add an updateProfile method to your DatabaseHelper
    // For now, assuming you can execute raw SQL or add the method:
    final db = await _dbHelper.database;
    await db.rawUpdate('UPDATE users SET nickname = ? WHERE id = 1', [_nameController.text]);
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF238E5F)),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nickname", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}