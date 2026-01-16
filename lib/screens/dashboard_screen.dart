import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'goal_details_screen.dart';
import 'add_goal_screen.dart';
import 'transaction_history_screen.dart';
import 'dart:io';
import 'all_goals_screen.dart';
import 'add_saving_screen.dart';
import 'statistics_screen.dart';
import 'passbook_screen.dart';
import 'notifications_screen.dart'; // ADD THIS IMPORT
import 'profile_screen.dart'; // ADD THIS IMPORT

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
  int _refreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final userProfile = await _dbHelper.getUserProfile();
    final name = userProfile?['nickname'] ?? "User";
    final goals = await _dbHelper.getAllGoals();
    final total = await _dbHelper.getTotalBalance();

    if (mounted) {
      setState(() {
        _userName = name;
        _goals = goals;
        _totalBalance = total;
        _isLoading = false;
        _refreshTrigger++;
      });
    }
  }

  Future<void> _deleteGoal(int id) async {
    await _dbHelper.deleteGoal(id);
    _loadDashboardData();
  }

  void _showAddMoneyDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSavingScreen()),
    );

    if (result == true) {
      _loadDashboardData();
    }
  }

  Widget _buildDashboardUI() {
    // ... (This code remains exactly the same as previous steps)
    // Just copying the structure for context:
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... Total Savings Card ...
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
                            Text("Total Saved", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AllGoalsScreen()),
                          ).then((_) => _loadDashboardData());
                        }, 
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
                      physics: const NeverScrollableScrollPhysics(), 
                      shrinkWrap: true,
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        final progress = (goal['current_amount'] / goal['target_amount']).clamp(0.0, 1.0);
                        return _buildGoalCard(context, goal, progress);
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
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen()));
                if (result == true) {
                  _loadDashboardData(); 
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
    );
  }

  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> goal, double progress) {
    // ... (Keep existing goal card logic)
    String imagePath = goal['image_path'] ?? 'assets/walkthrough.jpg';
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetailsScreen(
          goalId: goal['id'],
          title: goal['title'],
          savedAmount: "₱${goal['current_amount']}",
          targetAmount: "₱${goal['target_amount']}",
          progress: progress,
          imagePath: imagePath,
        )));
        _loadDashboardData(); 
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal['title'], 
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                          color: const Color(0xFF01140E),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddGoalScreen(goal: goal)));
                              if (result == true) _loadDashboardData();
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF01140E),
                                  title: Text("Delete Goal?", style: GoogleFonts.poppins(color: Colors.white)),
                                  content: Text("Are you sure you want to delete '${goal['title']}'?", style: GoogleFonts.poppins(color: Colors.white70)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                                    TextButton(onPressed: () {Navigator.pop(ctx); _deleteGoal(goal['id']);}, child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
                                  ],
                                )
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF238E5F)))),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("₱${goal['current_amount']}", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                    Text("${(progress * 100).toInt()}%", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _selectedIndex == 0 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                Text(_userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            )
          : null,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                // FIXED: Navigate to Notifications Inbox (History)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
          )
        ],
      ),

      // MAIN CONTENT SWITCHER
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardUI(),       // Index 0: Home
          StatisticsScreen(),        // Index 1: Stats
          PassbookScreen(refreshTrigger: _refreshTrigger), // Index 2: Wallet
          const ProfileScreen(),     // Index 3: Profile (With Settings)
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
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Passbook"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}