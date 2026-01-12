import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'goal_details_screen.dart';
import 'add_goal_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            Text("User!", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),

      body: Column(
        children: [
          // 1. SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOTAL SAVINGS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF015940), Color(0xFF023828)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF015940).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Savings", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                            // HISTORY BUTTON
                            InkWell(
                              onTap: () {
                                 Navigator.push(context, MaterialPageRoute(
                                   builder: (context) => const TransactionHistoryScreen(title: "All History", amount: "Summary")));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.history, color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("\$ 12,500.00", style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            // + BUTTON
                            FloatingActionButton.small(
                              onPressed: () {}, 
                              backgroundColor: Colors.white,
                              heroTag: "add_money", // Unique tag to avoid conflicts
                              child: const Icon(Icons.add, color: Color(0xFF015940)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // GOALS HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Goals", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {}, 
                        child: Text("View All", style: GoogleFonts.poppins(color: const Color(0xFF238E5F))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // GOALS LIST
                  _buildGoalCard(
                    context,
                    "Dream Car",
                    "\$15,000",
                    "\$30,000",
                    0.5,
                    "assets/walkthrough.jpg",
                  ),
                  _buildGoalCard(
                    context,
                    "New Laptop",
                    "\$1,200",
                    "\$2,000",
                    0.6,
                    "assets/walkthrough.jpg",
                  ),
                ],
              ),
            ),
          ),

          // "ADD GOAL" BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238E5F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_task, color: Colors.white),
                label: Text(
                  "Add New Goal", 
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR  ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF01140E),
          selectedItemColor: const Color(0xFF238E5F),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Stats"),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, String saved, String target, double progress, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailsScreen(
          title: title,
          savedAmount: saved,
          targetAmount: target,
          progress: progress,
          imagePath: imagePath,
        )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF238E5F)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(saved, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Text("${(progress * 100).toInt()}%", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}