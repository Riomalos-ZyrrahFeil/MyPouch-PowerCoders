import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoneySourceScreen extends StatelessWidget {
  const MoneySourceScreen({super.key});

  final List<Map<String, dynamic>> sources = const [
    {"name": "Cash", "icon": Icons.money},
    {"name": "Alkansya", "icon": Icons.savings_outlined},
    {"name": "GCash", "icon": Icons.account_balance_wallet_outlined},
    {"name": "Maya", "icon": Icons.qr_code},
    {"name": "Bank Account", "icon": Icons.account_balance},
    {"name": "Other", "icon": Icons.more_horiz},
  ];

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
        title: Text("Select Money Source", style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: sources.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(sources[index]['icon'], color: const Color(0xFF238E5F), size: 24),
            ),
            title: Text(
              sources[index]['name'],
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {
              Navigator.pop(context, sources[index]['name']);
            },
          );
        },
      ),
    );
  }
}