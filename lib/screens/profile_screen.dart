import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'edit_profile_screen.dart';
import 'security_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'backup_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _nickname = "User";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _dbHelper.getUserProfile();
    if (mounted && user != null) {
      setState(() {
        _nickname = user['nickname'] ?? "User";
        _profileImagePath = user['image_path']; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // PROFILE IMAGE
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF238E5F), width: 2),
                  // Logic: Show FileImage if path exists, else show asset logo
                  image: _profileImagePath != null && File(_profileImagePath!).existsSync()
                      ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover)
                      : const DecorationImage(image: AssetImage('assets/logo.png'), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name
              Text(
                _nickname,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              
              const SizedBox(height: 8),

              // EDIT PROFILE BUTTON
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    // Wait for Edit Screen to close, then reload data
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    _loadProfile(); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 40),

              // SETTINGS GROUPS
              _buildSectionTitle("General"),
              _buildSettingsTile(
                icon: Icons.notifications_outlined, 
                title: "Notifications", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
              ),
              _buildSettingsTile(
                icon: Icons.security, 
                title: "Security", 
                subtitle: "PIN, Recovery & Reset",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsScreen())),
              ),

              const SizedBox(height: 30),
              
              // DATA & ABOUT
              _buildSectionTitle("Data & Support"),
              _buildSettingsTile(
                icon: Icons.cloud_upload_outlined, 
                title: "Backup Data", 
                subtitle: "Export CSV & Restore",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen())),
              ),
              _buildSettingsTile(
                icon: Icons.info_outline, 
                title: "About", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
              ),
              
              const SizedBox(height: 40),
              
              Text("MyPouch v1.0.0", style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(title, style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.white70),
        ),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}