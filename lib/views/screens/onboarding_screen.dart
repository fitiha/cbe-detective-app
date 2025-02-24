import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final box = GetStorage();
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // for automatic sliding timer
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _currentIndex++;
      if (_currentIndex >= 2) {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/onboarding_logo.png',
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    _buildPageIndicator(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index % 2;
                          });
                        },
                        itemCount: 2, // Number of pages
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                index % 2 == 0
                                     ? 'Receipt Validation Made Easy'
                                    : 'Track Your Purchases and Validate Receipts for Tax Purposes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                index % 2 == 0
                                    ? 'A quick and easy way to validate your receipts and manage your financial records.'
                                    : 'Ensure accurate receipt validation for tax purposes and keep track of your purchases efficiently.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  height: 22 / 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Container(
                            width: 135,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('login-page');
                                box.write('onboardingCompleted', true);
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                  height: 20 / 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFEEEFF0),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ).copyWith(
                                side: WidgetStateProperty.all(
                                  BorderSide(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Container(
                            width: 135,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('signup-page');
                                box.write('onboardingCompleted', true);
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                  height: 20 / 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFEEEFF0),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ).copyWith(
                                side: WidgetStateProperty.all(
                                  BorderSide(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          height: 6.0,
          width: _currentIndex == index ? 24.0 : 6.0,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(3.0),
          ),
        );
      }),
    );
  }
}
