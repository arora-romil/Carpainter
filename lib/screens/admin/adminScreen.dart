import 'package:carpainter/screens/admin/adminScreenContent.dart';
import 'package:carpainter/screens/admin/carpenterlistScreen.dart';
import 'package:carpainter/screens/admin/requestScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  final List<Widget> _screens = [
    const AdminScreenContent(),
    CarpenterListScreen(),
    const RequestsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Define the fade-in effect (opacity animation)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start the animation when the page opens
    Future.delayed(const Duration(milliseconds: 50), () {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: FadeTransition(
          opacity: _opacityAnimation,
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          items: const <Widget>[
            Icon(
              Icons.admin_panel_settings,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.handyman,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.request_page,
              size: 30,
              color: Colors.white,
            ),
          ],
          color: const Color(0xFF493628),
          buttonBackgroundColor: const Color(0xFFAB886D),
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
