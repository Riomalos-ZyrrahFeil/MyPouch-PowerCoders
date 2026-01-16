import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/database_helper.dart';
import 'splash_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  /// Helper to get the actual Downloads directory
  Future<String?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getDownloadsDirectory();
      }
    } catch (err) {
      debugPrint("Could not get download path: $err");
    }
    return directory?.path;
  }

  // Export CSV (Keep existing logic)
  Future<void> _exportCsv() async {
    setState(() => _isLoading = true);
    try {
      String csvData = await _dbHelper.exportDataToCsv();
      final path = await _getDownloadPath();
      
      if (path != null) {
        final fileName = 'MyPouch_Data_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('$path/$fileName');
        await file.writeAsString(csvData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Saved to Downloads: $fileName"),
            backgroundColor: const Color(0xFF238E5F),
            duration: const Duration(seconds: 4),
          ));
        }
      } else {
        throw "Could not find Downloads folder";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Export JSON
  Future<void> _createBackupFile() async {
    setState(() => _isLoading = true);
    try {
      String jsonData = await _dbHelper.exportDataToJson();
      final path = await _getDownloadPath();

      if (path != null) {
        final fileName = 'MyPouch_Backup_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('$path/$fileName');
        await file.writeAsString(jsonData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Backup saved to Downloads: $fileName"),
            backgroundColor: const Color(0xFF238E5F),
            duration: const Duration(seconds: 4),
          ));
        }
      } else {
        throw "Could not find Downloads folder";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup creation failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Restore from Backup
  Future<void> _restoreFromBackup() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, 
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        
        if (path == null) throw "Could not retrieve file path.";

        File file = File(path);
        String content = await file.readAsString();
        
        // Validate JSON format roughly
        if (content.trim().startsWith('{')) {
          
          // Perform Restore
          await _dbHelper.importDataFromJson(content);
          
          if (mounted) {
            // Show Success Dialog & RESTART APP
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF01140E),
                title: Text("Restore Complete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                content: Text(
                  "Your data has been successfully restored. The app will now restart to load your data.", 
                  style: GoogleFonts.poppins(color: Colors.white70)
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      
                      // FORCE APP RESTART (Clear stack and go to Splash)
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const SplashScreen()), 
                        (route) => false,
                      );
                    }, 
                    child: Text("OK", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.bold))
                  ),
                ],
              ),
            );
          }
        } else {
           throw "Invalid file format. Please select a valid .json backup file.";
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Restore failed: $e"),
            backgroundColor: Colors.redAccent,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("Backup & Restore", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildActionCard(
              title: "Export as CSV",
              description: "View your data in Excel or Sheets",
              icon: Icons.table_view_outlined,
              buttonText: "Export CSV",
              buttonColor: Colors.white10,
              onTap: _exportCsv,
            ),

            const SizedBox(height: 40), 

            Text("Transfer Data", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF238E5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF238E5F)),
              ),
              child: Column(
                children: [
                  _buildInternalButton(
                    icon: Icons.save_alt,
                    title: "Create Backup File",
                    subtitle: "Save a JSON file to move data to another phone",
                    onTap: _createBackupFile,
                  ),
                  
                  Divider(color: const Color(0xFF238E5F).withOpacity(0.3), height: 32),

                  _buildInternalButton(
                    icon: Icons.restore_page_outlined,
                    title: "Restore from Backup",
                    subtitle: "This will overwrite the current data",
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF01140E),
                          title: Text("Overwrite Data?", style: GoogleFonts.poppins(color: Colors.white)),
                          content: Text("Restoring will delete all current goals and history on this device. Are you sure?", style: GoogleFonts.poppins(color: Colors.white70)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _restoreFromBackup();
                              }, 
                              child: const Text("Restore", style: TextStyle(color: Colors.redAccent))
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String description, required IconData icon, required String buttonText, required VoidCallback onTap, required Color buttonColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(description, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: Text(buttonText, style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalButton({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: GoogleFonts.poppins(color: isDestructive ? Colors.redAccent.withOpacity(0.7) : Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}