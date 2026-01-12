import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'goal_details_screen.dart';
import 'add_goal_screen.dart';

class AllGoalsScreen extends StatefulWidget {
  const AllGoalsScreen({super.key});

  @override
  State<AllGoalsScreen> createState() => _AllGoalsScreenState();
}

class _AllGoalsScreenState extends State<AllGoalsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    final goals = await _dbHelper.getAllGoals();
    if (mounted) {
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    }
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text("All Goals", style: GoogleFonts.poppins(color: Colors.white)),
        actions: [
          // Option to add a goal directly from this screen
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGoalScreen()),
              );
              if (result == true) {
                _loadGoals();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF238E5F)))
          : _goals.isEmpty
              ? Center(
                  child: Text(
                    "No goals found.",
                    style: GoogleFonts.poppins(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final progress = (goal['current_amount'] / goal['target_amount']).clamp(0.0, 1.0);
                    
                    return _buildGoalCard(context, goal, progress);
                  },
                ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> goal, double progress) {
    String imagePath = goal['image_path'] ?? 'assets/walkthrough.jpg';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalDetailsScreen(
              goalId: goal['id'],
              title: goal['title'],
              savedAmount: "₱${goal['current_amount']}",
              targetAmount: "₱${goal['target_amount']}",
              progress: progress,
              imagePath: imagePath,
            ),
          ),
        );
        _loadGoals();
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
                image: DecorationImage(
                  image: imagePath.startsWith('assets/')
                      ? AssetImage(imagePath) as ImageProvider
                      : FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
                      Text(
                        "₱${goal['current_amount']}",
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF238E5F),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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