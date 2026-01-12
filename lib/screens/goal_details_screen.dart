import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalDetailsScreen extends StatelessWidget {
  final String title;
  final String savedAmount;
  final String targetAmount;
  final double progress; // 0.0 to 1.0
  final String imagePath;

  const GoalDetailsScreen({
    super.key,
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.progress,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      body: CustomScrollView(
        slivers: [
          // 1. Image Header
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF01140E),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              background: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                color: Colors.black45, // Darken image slightly for text readability
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // 2. Progress Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Saved", style: GoogleFonts.poppins(color: Colors.white70)),
                          Text(savedAmount, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Target", style: GoogleFonts.poppins(color: Colors.white70)),
                          Text(targetAmount, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF238E5F)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toInt()}% Achieved",
                    style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // 3. Transactions List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                "Goal Transactions",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 4. Transactions List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildTransactionTile("Deposit", "Today", "+\$500.00");
              },
              childCount: 5, // Dummy count
            ),
          ),
        ],
      ),
      // FAB to Add Money to this Goal
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF238E5F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Funds", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String date, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_downward, color: Color(0xFF238E5F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(date, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: const Color(0xFF238E5F),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}