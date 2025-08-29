import 'package:carpainter/screens/admin/adminScreen.dart';
import 'package:carpainter/screens/carpenter/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _otp = "";
  bool _isLoading = false;
  late String verificationId;
  late String phoneNumber;
  double _logoOpacity = 0.0;
  double _formOpacity = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    verificationId = args['verificationId']!;
    phoneNumber = args['phoneNumber']!;
  }

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Start below screen
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Trigger animations
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _formOpacity = 1.0;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not found.");
      }

      String phoneNumber = user.phoneNumber ?? "";

      final adminDoc =
          await _firestore.collection('admins').doc(phoneNumber).get();
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      print(adminDoc);
      print(phoneNumber);

      if (adminDoc.exists) {
        // ✅ User is an admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else if (userDoc.exists) {
        // ✅ User is a normal user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // ❌ User is not found, go to registration
        Navigator.pushReplacementNamed(context, 'registration');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _logoOpacity,
                  child: Image.asset(
                    'assets/auth2.png',
                    width: 250,
                    height: 250,
                    color: const Color(0xFF493628),
                  ),
                ),
                const SizedBox(height: 25),

                // Form Slide Animation
                SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _formOpacity,
                    child: Column(
                      children: [
                        const Text(
                          "Phone Verification",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "We need to register your phone to get started!",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        Pinput(
                          length: 6,
                          showCursor: true,
                          onChanged: (value) {
                            _otp = value;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Button Animation
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : ElevatedButton(
                                    key: const ValueKey("verifyButton"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF493628),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _isLoading ? null : _verifyOtp,
                                    child: const Text(
                                      "Verify OTP",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ),
                        ),

                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'phone',
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Edit Phone Number?",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
