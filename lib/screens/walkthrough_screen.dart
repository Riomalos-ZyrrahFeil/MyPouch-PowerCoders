import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_flow_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _markWalkthroughAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walkthrough_seen', true);
  }

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Your Digital Alkansya is Here.", 
      "desc": "Welcome to My Pouch PH! Turn your savings habit into a visual journey and reach your financial dreams, one peso at a time.",
      "image": "assets/WalkThrough_1.png"
    },
    {
      "title": "What are you saving for?",
      "desc": "Create a custom goal—whether it’s a new phone, a concert ticket, or an emergency fund. Set your target amount and upload a photo to keep your eyes on the prize.",
      "image": "assets/WalkThrough_2.png"
    },
    {
      "title": "Track Every Contribution.",
      "desc": "Dropped a coin in your jar? Saved your allowance? Manually log your savings in seconds and watch your progress bar fill up. No bank linking required.",
      "image": "assets/WalkThrough_3.png"
    },
    {
      "title": "Celebrate Your Wins!",
      "desc": "Stay consistent with motivational feedback. When you hit your target, unlock a special celebration screen. You earned it!",
      "image": "assets/WalkThrough_4.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF015940), // Top Green
              Color(0xFF01140E), // Bottom Dark/Black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Image Section
              Expanded(
                flex: 4, 
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Image.asset(
                        _onboardingData[index]['image']!,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),

              // 2. Text and Button Section
              Expanded(
                flex: 3, 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => buildDot(index),
                        ),
                      ),

                      // Text Content
                      Column(
                        children: [
                          Text(
                            _onboardingData[_currentPage]['title']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF238E5F),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _onboardingData[_currentPage]['desc']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _onboardingData.length - 1) {
                              // Mark walkthrough as seen
                              _markWalkthroughAsSeen();
                              // Navigate to Setup Flow (account creation)
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetupFlowScreen(
                                    onSetupComplete: () {
                                      // After setup is complete, navigate to home
                                      // This will be handled by the splash screen logic
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF238E5F),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dots Helper
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 32 : 8, 
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? const Color(0xFF238E5F)
            : Colors.white24, 
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}