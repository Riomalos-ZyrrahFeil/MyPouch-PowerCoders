import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
 
  // State variables
  Map<int, double> _activityData = {};
  Map<String, double> _goalDistribution = {};
  int _streak = 0;
  double _dailyAverage = 0.0;
  String _topGoalName = "Goal";
  double _topGoalTarget = 0.0;
  double _topGoalCurrent = 0.0;
  bool _isLoading = true;
  int _timeFilterIndex = 1; // 1: Week, 2: Month, 3: Year

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    // 1. Fetch data based on the current filter index
    final activity = await _dbHelper.getActivityData(_timeFilterIndex);
    final distribution = await _dbHelper.getGoalDistribution();
    final streak = await _dbHelper.getStreak();
    final average = await _dbHelper.getDailyAverage();
    final goals = await _dbHelper.getAllGoals();

    String tName = "Goal";
    double tTarget = 0;
    double tCurrent = 0;
   
    if (goals.isNotEmpty) {
      final mainGoal = goals.first;
      tName = mainGoal['title'];
      tTarget = (mainGoal['target_amount'] as num).toDouble();
      tCurrent = (mainGoal['current_amount'] as num).toDouble();
    }

    if (mounted) {
      setState(() {
        _activityData = activity;
        _goalDistribution = distribution;
        _streak = streak;
        _dailyAverage = average;
        _topGoalName = tName;
        _topGoalTarget = tTarget;
        _topGoalCurrent = tCurrent;
        _isLoading = false;
      });
    }
  }

  // Helper to generate dynamic labels (M/T/W vs 1/5/10 vs J/F/M)
  String _getLabel(int index) {
    if (_timeFilterIndex == 1) { // WEEK
      return ["M", "T", "W", "T", "F", "S", "S"][index];
    } else if (_timeFilterIndex == 2) { // MONTH
      int day = index + 1;
      // Show label every 5 days so it fits
      return (day == 1 || day % 5 == 0) ? "$day" : "";
    } else { // YEAR (or All)
      return ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"][index];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF238E5F)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01140E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text("Statistics", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),

              // TIME FILTER BUTTONS
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: ["All", "Week", "Month", "Year"].asMap().entries.map((entry) {
                    bool isSelected = _timeFilterIndex == entry.key;
                    // Map "All" (0) to "Year" (3) logic for simplicity
                    if (entry.key == 0 && _timeFilterIndex == 3) isSelected = true;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // 2. Logic to update filter and RELOAD data
                          int newIndex = entry.key == 0 ? 3 : entry.key;
                          setState(() {
                             _timeFilterIndex = newIndex;
                             _isLoading = true; // Show loading to prevent glitch
                             _activityData = {}; // Clear old data
                          });
                          _loadStatistics(); // Fetch new data!
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF238E5F) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // STREAK & AVERAGE
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      color: Colors.orangeAccent,
                      title: "$_streak Day Streak",
                      subtitle: "Keep it up!",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.show_chart,
                      color: const Color(0xFF238E5F),
                      title: "₱${_dailyAverage.toStringAsFixed(0)}",
                      subtitle: "Daily Average",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildProjectionCard(),
              const SizedBox(height: 24),

              // DYNAMIC ACTIVITY CHART
              Text("Activity", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _activityData.isEmpty
                  ? Center(child: Text("No data available", style: GoogleFonts.poppins(color: Colors.white54)))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_activityData.length, (index) {
                        int key = index + 1;
                        double amount = _activityData[key] ?? 0;
                        double max = _activityData.values.reduce((a, b) => a > b ? a : b);
                        if (max == 0) max = 1;
                        double heightFactor = (amount / max);

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Show amount if > 0
                              if (amount > 0 && (_timeFilterIndex == 1 || _timeFilterIndex == 3))
                                FittedBox(
                                  child: Text("₱${amount.toInt()}", 
                                    style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontSize: 8, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              const SizedBox(height: 4),
                              // Bar
                              Container(
                                width: _timeFilterIndex == 2 ? 4 : 12, // Thinner bars for Month
                                height: 100 * heightFactor + 2,
                                decoration: BoxDecoration(
                                  color: amount > 0 ? const Color(0xFF238E5F) : Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Label
                              Text(
                                _getLabel(index),
                                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
              ),
              const SizedBox(height: 24),

              // PIE CHART
              Text("Allocation", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _goalDistribution.isEmpty
                  ? Center(child: Text("No data yet", style: GoogleFonts.poppins(color: Colors.white54)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _goalDistribution.entries.map((e) {
                          return PieChartSectionData(
                            color: Colors.primaries[_goalDistribution.keys.toList().indexOf(e.key) % Colors.primaries.length],
                            value: e.value,
                            title: "${((e.value / _goalDistribution.values.reduce((a, b) => a + b)) * 100).toInt()}%",
                            radius: 50,
                            titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
              ),
              
              if (_goalDistribution.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: _goalDistribution.entries.map((e) {
                      int idx = _goalDistribution.keys.toList().indexOf(e.key) % Colors.primaries.length;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.primaries[idx], shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(e.key, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProjectionCard() {
    int daysRemaining = 0;
    if (_dailyAverage > 0 && _topGoalTarget > _topGoalCurrent) {
      daysRemaining = ((_topGoalTarget - _topGoalCurrent) / _dailyAverage).ceil();
    }
    if (_topGoalTarget == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF238E5F), Color(0xFF015940)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("At this rate,", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, height: 1.5),
              children: [
                const TextSpan(text: "you'll reach your "),
                TextSpan(text: _topGoalName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: " goal in "),
                TextSpan(text: "$daysRemaining days", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}