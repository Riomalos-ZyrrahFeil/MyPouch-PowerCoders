import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isDailyReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // Default 8:00 PM

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDailyReminderEnabled = prefs.getBool('daily_reminder') ?? false;
      final int hour = prefs.getInt('reminder_hour') ?? 20;
      final int minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDailyReminderEnabled = value);
    await prefs.setBool('daily_reminder', value);

    if (value) {
      // 1. Request Permission
      final granted = await NotificationService().requestPermissions();
      
      if (granted) {
        // 2. Schedule Notification
        await _scheduleNotification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Daily reminder enabled!")),
          );
        }
      } else {
        // Permission denied, revert switch
        setState(() => _isDailyReminderEnabled = false);
        await prefs.setBool('daily_reminder', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission required to show notifications.")),
          );
        }
      }
    } else {
      // 3. Cancel Notification
      await NotificationService().cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daily reminder disabled.")),
        );
      }
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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
      setState(() => _reminderTime = picked);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);

      // If enabled, reschedule with new time
      if (_isDailyReminderEnabled) {
        await NotificationService().cancelAll(); // Clear old time
        await _scheduleNotification(); // Set new time
      }
    }
  }

  Future<void> _scheduleNotification() async {
    await NotificationService().scheduleDailyNotification(
      id: 1,
      title: "Time to Save! 💰",
      body: "Don't break your streak. Add to your pouch today.",
      time: _reminderTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Notifications", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text("Daily Reminder", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text("Get a daily nudge to save", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                value: _isDailyReminderEnabled,
                activeColor: const Color(0xFF238E5F),
                onChanged: _toggleReminder,
              ),
            ),
            
            const SizedBox(height: 16),

            if (_isDailyReminderEnabled)
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF238E5F).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Reminder Time", style: GoogleFonts.poppins(color: Colors.white)),
                      Row(
                        children: [
                          Text(
                            _reminderTime.format(context),
                            style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, color: Colors.white54, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
// ... (rest of your build code)

            const Spacer(),
            
            // TEST BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  NotificationService().showInstantNotification();
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                child: Text("Test Notification Now", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}