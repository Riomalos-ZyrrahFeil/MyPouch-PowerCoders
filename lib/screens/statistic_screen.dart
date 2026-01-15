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
  Map<int, double> _weeklyActivity = {};
  Map<String, double> _goalDistribution = {};
  int _streak = 0;
  double _dailyAverage = 0.0;
  String _topGoalName = "Goal";
  double _topGoalTarget = 0.0;
  double _topGoalCurrent = 0.0;
  bool _isLoading = true;
  int _timeFilterIndex = 1; // 0: All, 1: Week, 2: Month, 3: Year

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final weekly = await _dbHelper.getWeeklyActivity();
    final distribution = await _dbHelper.getGoalDistribution();
    final streak = await _dbHelper.getStreak();
    final average = await _dbHelper.getDailyAverage();
   
    // Get the active goal with the highest target for the "Projection" card
    final goals = await _dbHelper.getAllGoals();
    String tName = "Goal";
    double tTarget = 0;
    double tCurrent = 0;
   
    if (goals.isNotEmpty) {
      // Logic: Pick the first active goal, or sort by priority
      final mainGoal = goals.first;
      tName = mainGoal['title'];
      tTarget = (mainGoal['target_amount'] as num).toDouble();
      tCurrent = (mainGoal['current_amount'] as num).toDouble();
    }

    if (mounted) {
      setState(() {
        _weeklyActivity = weekly;
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
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _timeFilterIndex = entry.key),
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

              // STREAK & AVERAGE ROW
              Row(
                children: [
                  // Streak Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 28),
                          const SizedBox(height: 8),
                          Text("$_streak Day Streak", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Keep it up!", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Average Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.show_chart, color: Color(0xFF238E5F), size: 28),
                          const SizedBox(height: 8),
                          Text("₱${_dailyAverage.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Daily Average", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // PROJECTION MESSAGE CARD
              _buildProjectionCard(),
              const SizedBox(height: 24),

              // ACTIVITY CHART (Mockup style bars)
              Text("Activity", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    int day = index + 1; // 1=Mon
                    double amount = _weeklyActivity[day] ?? 0;
                    double max = _weeklyActivity.values.reduce((a, b) => a > b ? a : b);
                    if (max == 0) max = 1;
                    double heightFactor = (amount / max);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (amount > 0)
                          Text("₱${amount.toInt()}", style: GoogleFonts.poppins(color: const Color(0xFF238E5F), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          width: 12,
                          height: 100 * heightFactor + 10, // Min height
                          decoration: BoxDecoration(
                            color: amount > 0 ? const Color(0xFF238E5F) : Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ["M", "T", "W", "T", "F", "S", "S"][index],
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // GOAL DISTRIBUTION (Pie Chart)
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
              // Legend
              Wrap(
                spacing: 16,
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
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectionCard() {
    // Calculate days remaining based on daily average
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
          Text(
            "At this rate,",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, height: 1.5),
              children: [
                const TextSpan(text: "you'll reach your "),
                TextSpan(
                  text: _topGoalName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const TextSpan(text: " goal in "),
                TextSpan(
                  text: "$daysRemaining days",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}