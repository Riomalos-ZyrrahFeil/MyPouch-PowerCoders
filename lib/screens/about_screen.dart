import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("About", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 24),
              Text("MyPouch", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Version 1.0.0", style: GoogleFonts.poppins(color: Colors.white54)),
              const SizedBox(height: 40),
              Text(
                "MyPouch is your offline-first financial companion. Track goals, visualize progress, and build better habits—all without leaving your device.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, height: 1.5),
              ),
              const Spacer(),
              Text("© 2026 PowerCoders", style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}