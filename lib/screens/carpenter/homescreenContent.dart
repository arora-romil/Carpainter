import 'package:carpainter/screens/admin/carpenterlistScreen.dart';
import 'package:carpainter/screens/carpenter/homePage.dart';
import 'package:carpainter/screens/carpenter/pointsHistory.dart';
import 'package:carpainter/screens/carpenter/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName = "";
  int totalPoints = 0;
  int pointsRedeemed = 0;
  bool isLoading = true;
  String requestStatus = ""; // To store redeem request status
  String profileRequestStatus = ""; // For profile approval request

  String? photoUrl; // Store user profile photo URL

  final List<Widget> _screens = [
    HomeScreenContent(),
    CarpenterListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _checkRedeemRequest();
  }

  // Fetch user name and points
  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return;

      setState(() {
        userName = "${userDoc['firstName']} ${userDoc['lastName']}";
        totalPoints = userDoc['points'] ?? 0;
        pointsRedeemed = userDoc['pointsRedeemed'] ?? 0;
        photoUrl = userDoc['photoUrl'];
        profileRequestStatus = (userDoc.data() as Map<String, dynamic>)
                .containsKey('profileRequest')
            ? userDoc['profileRequest']
            : "pending"; // Fetch approval status
        isLoading = false;
      });

      // If profileRequest doesn't exist, set it to "pending"
      if (!userDoc.data().toString().contains('profileRequest')) {
        await _firestore.collection('users').doc(user.uid).update({
          'profileRequest': "pending",
        });
      }
    }
  }

  // Check if the user has a pending request
  Future<void> _checkRedeemRequest() async {
    final user = _auth.currentUser;
    if (user != null) {
      final requestSnapshot = await _firestore
          .collection('requests')
          .where('uid', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (requestSnapshot.docs.isNotEmpty) {
        setState(() {
          requestStatus = requestSnapshot.docs.first['status'];
          print("Request status: $requestStatus");
        });
      }
    }
  }

  Future<void> _redeemPoints() async {
    isLoading = false;
    final user = _auth.currentUser;
    if (user == null) return;

    if (totalPoints < 10) {
      _showDialog(
        "Insufficient Points",
        "You need at least 10 points to redeem.",
      );
      return;
    }

    final TextEditingController pointsController = TextEditingController();

    // Show the input dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF493628),
          title: const Text(
            "Redeem Points",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter points to redeem",
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                int redeemAmount = int.tryParse(pointsController.text) ?? 0;
                if (redeemAmount <= 0 || redeemAmount > totalPoints) {
                  _showDialog(
                    "Invalid Amount",
                    "Enter a valid number of points.",
                  );
                  return;
                }

                // Close the input dialog
                Navigator.pop(context);

                // Show the loader dialog
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF493628)),
                    );
                  },
                );

                try {
                  // Submit the redeem request
                  await _firestore.collection('requests').add({
                    'uid': user.uid,
                    'redeemPoints': redeemAmount,
                    'status': 'pending',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // Update UI after submission
                  setState(() {
                    requestStatus = "pending";
                  });

                  // Dismiss the loader dialog
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context, rootNavigator: true).pop();
                  });

                  // Show success dialog
                  _showDialog(
                    "Success",
                    "Your redeem request has been submitted.",
                  );
                } catch (e) {
                  // Dismiss the loader dialog
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context, rootNavigator: true).pop();
                  });
                  // Show error dialog
                  _showDialog(
                    "Error",
                    "Something went wrong. Please try again.",
                  );
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show alert dialog
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  ),
              child: Text(
                "Okay",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive app bar height (adjust based on screen height)
    final appBarHeight = screenHeight * 0.25; // 25% of screen height

    // Responsive font sizes
    final titleFontSize = screenWidth * 0.07; // 6% of screen width
    final subtitleFontSize = screenWidth * 0.04; // 4% of screen width
    final iconSize = screenWidth * 0.2; // 10% of screen width

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight), // Dynamic height
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF493628), const Color(0xFFA8653B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: iconSize * 0.5,
                    backgroundColor: Colors.white,
                    backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                        ? NetworkImage(photoUrl!) // Show profile image
                        : null, // Default: no image
                    child: photoUrl == null || photoUrl!.isEmpty
                        ? Icon(Icons.person,
                            size: iconSize * 0.5,
                            color: const Color(0xFFA8653B))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Hello, ${userName ?? 'Guest'}!",
                          style: TextStyle(
                            fontSize: titleFontSize, // Dynamic font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 8),
                  profileRequestStatus == ""
                      ? Text(
                          "Profile Request: NA",
                          style: TextStyle(
                            fontSize: subtitleFontSize, // Dynamic font size
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "Profile Request: $profileRequestStatus",
                          style: TextStyle(
                            fontSize: subtitleFontSize, // Dynamic font size
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: IntrinsicHeight(
                  // Ensures child widgets take necessary height
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      /// **Logo (Fixed Height)**
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Image.asset(
                          'assets/logo2.png',
                          color: const Color(0xFFA8653B),
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// **Redeem Button**
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: profileRequestStatus == "pending"
                              ? Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Wait for admin approval",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: requestStatus == "pending"
                                      ? null
                                      : _redeemPoints,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: requestStatus == "pending"
                                        ? Colors.grey
                                        : const Color(0xFFA8653B),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 20,
                                    shadowColor: Colors.black.withOpacity(0.8),
                                  ),
                                  child: Text(
                                    requestStatus == "pending"
                                        ? "Request Pending"
                                        : "Redeem Points",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// **Point Cards (Fixed Height)**
                      SizedBox(
                        height: 200, // Fixed height to avoid flex issue
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: _buildCircularPointCard(
                                title: "Points Redeemed",
                                points: pointsRedeemed,
                                gradientColors: [
                                  const Color(0xFFA8653B),
                                  const Color(0xFF493628),
                                ],
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PointsHistoryScreen(
                                          userId: _auth.currentUser!.uid),
                                    ),
                                  );
                                },
                                child: _buildCircularPointCard(
                                  title: "Total Points",
                                  points: totalPoints,
                                  gradientColors: [
                                    const Color(0xFF493628),
                                    const Color(0xFFA8653B),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCircularPointCard({
    required String title,
    required int points,
    required List<Color> gradientColors,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: 180,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  "$points",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF493628),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
