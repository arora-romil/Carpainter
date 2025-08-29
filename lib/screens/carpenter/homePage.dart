import 'package:carpainter/screens/carpenter/homescreenContent.dart';
import 'package:carpainter/screens/carpenter/profileScreen.dart';
import 'package:carpainter/screens/carpenter/schemeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName = "";
  int points = 0;
  int _selectedIndex = 0;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const SchemeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserName();

    // Initialize animation controller for fade-in effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Define the opacity animation (fade-in effect)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start the animation when the page opens
    Future.delayed(const Duration(milliseconds: 50), () {
      _animationController.forward();
    });
  }

  // Fetch the user name from Firestore
  Future<void> _getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = "${userDoc['firstName']} ${userDoc['lastName']}";
          points = userDoc['points'];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              )
            : FadeTransition(
                opacity: _opacityAnimation,
                child: _screens[_selectedIndex],
              ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          items: const <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.local_offer, size: 30, color: Colors.white),
            Icon(Icons.account_circle, size: 30, color: Colors.white),
          ],
          color: const Color(0xFF493628),
          buttonBackgroundColor: const Color(0xFFA8653B),
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
