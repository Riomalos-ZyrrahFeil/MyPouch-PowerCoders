import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart'; // Import DB
import 'goal_details_screen.dart';
import 'add_goal_screen.dart';
import 'transaction_history_screen.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String _userName = "User";
  double _totalBalance = 0.0;
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // 1. Get User Name
    final userProfile = await _dbHelper.getUserProfile();
    final name = userProfile?['nickname'] ?? "User";

    // 2. Get Goals
    final goals = await _dbHelper.getAllGoals();

    // 3. Get Total Balance
    final total = await _dbHelper.getTotalBalance();

    if (mounted) {
      setState(() {
        _userName = name;
        _goals = goals;
        _totalBalance = total;
        _isLoading = false;
      });
    }
  }

  // Handle adding money to a goal directly from Dashboard
  void _showAddMoneyDialog() {
    if (_goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Create a goal first!")));
      return;
    }
    
    // Simple logic: Add to the first goal for now, or you can make a picker
    // For this example, we push to the first goal's details to add money
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(
          goalId: _goals.first['id'],
          title: _goals.first['title'],
          savedAmount: _goals.first['current_amount'].toString(),
          targetAmount: _goals.first['target_amount'].toString(),
          progress: (_goals.first['current_amount'] / _goals.first['target_amount']).clamp(0.0, 1.0),
          imagePath: _goals.first['image_path'] ?? 'assets/walkthrough.jpg',
        ),
      ),
    ).then((_) => _loadDashboardData()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            Text(_userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
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
                          BoxShadow(color: const Color(0xFF015940).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Savings", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                              // History Button
                              InkWell(
                                onTap: () {
                                   Navigator.push(context, MaterialPageRoute(
                                     builder: (context) => const TransactionHistoryScreen(isGlobal: true)));
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
                              Text(
                                "₱ ${_totalBalance.toStringAsFixed(2)}", 
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                              ),
                              FloatingActionButton.small(
                                onPressed: _showAddMoneyDialog, 
                                backgroundColor: Colors.white,
                                heroTag: "add_money",
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
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_goals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("No goals yet. Add one below!", style: GoogleFonts.poppins(color: Colors.white54)),
                        ),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(), // Disable internal scroll
                        shrinkWrap: true,
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final progress = (goal['current_amount'] / goal['target_amount']).clamp(0.0, 1.0);
                          
                          return _buildGoalCard(
                            context,
                            goal['id'],
                            goal['title'],
                            "₱${goal['current_amount']}",
                            "₱${goal['target_amount']}",
                            progress,
                            goal['image_path'] ?? 'assets/walkthrough.jpg',
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ADD NEW GOAL BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF01140E),
              border: Border(top: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Wait for result from AddGoalScreen
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen()));
                  if (result == true) {
                    _loadDashboardData(); // Refresh if goal was added
                  }
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10, width: 1))),
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

  Widget _buildGoalCard(BuildContext context, int id, String title, String saved, String target, double progress, String imagePath) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailsScreen(
          goalId: id, // Pass ID to fetch details
          title: title,
          savedAmount: saved,
          targetAmount: target,
          progress: progress,
          imagePath: imagePath,
        )));
        _loadDashboardData(); // Refresh on return (in case funds added)
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
              width: 60, height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: imagePath.startsWith('assets/') 
                      ? AssetImage(imagePath) as ImageProvider 
                      : FileImage(File(imagePath)),
                  fit: BoxFit.cover
                ),
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
                      value: progress, minHeight: 6,
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