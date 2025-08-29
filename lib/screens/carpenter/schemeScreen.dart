import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Uint8List? pdfData;
  String profileRequestStatus = ""; // For profile approval request

  @override
  void initState() {
    super.initState();
    _getUserData();
    loadDocument();
  }

  // Load PDF document from assets
  loadDocument() async {
    final ByteData bytes = await rootBundle.load('assets/scheme.pdf');
    setState(() {
      pdfData = bytes.buffer.asUint8List();
      _isLoading = false;
    });
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return;

      setState(() {
        profileRequestStatus = (userDoc.data() as Map<String, dynamic>)
                .containsKey('profileRequest')
            ? userDoc['profileRequest']
            : "pending"; // Fetch approval status
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Scheme Details",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      body: profileRequestStatus == "pending"
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Profile approval pending",
                  style: TextStyle(fontSize: 18, color: Colors.brown),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please wait for your profile to be approved",
                  style: TextStyle(fontSize: 16, color: Colors.brown),
                ),
              ],
            ))
          : _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.brown))
              : PDFView(
                  filePath: null, // No file path needed
                  pdfData: pdfData, // Provide the in-memory PDF data
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.BOTH,
                  backgroundColor: Colors.white,
                ),
    );
  }
}
