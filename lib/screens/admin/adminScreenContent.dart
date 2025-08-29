import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AdminScreenContent extends StatefulWidget {
  const AdminScreenContent({super.key});

  @override
  _AdminScreenContentState createState() => _AdminScreenContentState();
}

class _AdminScreenContentState extends State<AdminScreenContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int carpenterCount = 0;
  int requestCount = 0; // Variable to store total requests count
  int totalRedeemedPoints = 0; // Variable to store total redeemed points
  bool isLoading = true;
  bool isAddingAdmin = false; // Variable to track admin addition loading state

  // Colors for app bar and cards
  List<Color> appBarColors = [
    Colors.green.shade800, // Carpenter card color
    Colors.blue.shade800, // Request card color
  ];
  Color currentAppBarColor = Color(0xFF493628);

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      // Fetch carpenter count
      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'carpenter')
          .get();

      // Fetch pending requests count (assuming 'status' field with value 'pending')
      final QuerySnapshot requestSnapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'pending') // Filter only pending requests
          .get();

      // Fetch total redeemed points from adminStats
      final DocumentSnapshot adminStatsSnapshot =
          await _firestore.collection('adminStats').doc('redeemedPoints').get();

      setState(() {
        carpenterCount = userSnapshot.size;
        requestCount =
            requestSnapshot.size; // Update requestCount with pending requests
        totalRedeemedPoints = adminStatsSnapshot.exists
            ? adminStatsSnapshot['totalRedeemedPoints'] ?? 0
            : 0; // Default to 0 if not available
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching counts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: currentAppBarColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: MediaQuery.of(context).size.width * 0.15,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Hello, Admin!",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Welcome to the Dashboard",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.brown)
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 2 / 1.1,
                        child: Image.asset(
                          'assets/logo2.png', // Replace with your logo asset path
                          fit: BoxFit.contain,
                          color: currentAppBarColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: _buildCard(
                          title: "Points Redeemed",
                          count: totalRedeemedPoints,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCircularPointCard(
                              title: "Carpenters",
                              count: carpenterCount,
                            ),
                            const SizedBox(width: 20),
                            _buildCircularPointCard(
                              title: "Requests",
                              count: requestCount,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAdminDialog(context);
        },
        backgroundColor: Colors.brown, // Customize the color
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required int count,
  }) {
    Color cardColor = Color(0xFF493628);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: cardColor, width: 4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: cardColor,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "$count",
              style: TextStyle(
                color: cardColor,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularPointCard({
    required String title,
    required int count,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: MediaQuery.of(context).size.width * 0.48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFAB886D),
              Color(0xFF493628),
            ],
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
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return LoaderOverlay(
          overlayColor: Colors.brown.withOpacity(0.5),
          child: AlertDialog(
            title: const Text("Add New Admin"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Admin Name",
                    labelStyle: TextStyle(color: Colors.brown),
                    prefixIcon: Icon(Icons.person, color: Colors.brown),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Admin Mobile Number",
                    labelStyle: TextStyle(color: Colors.brown),
                    prefixIcon: Icon(Icons.phone, color: Colors.brown),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.brown)),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isAddingAdmin = true;
                  });
                  String name = nameController.text.trim();
                  String phone = '+91${phoneController.text.trim()}';
                  print("Name: $name, Phone: $phone");

                  if (name.isNotEmpty && phone.isNotEmpty) {
                    await _addAdmin(name, phone);
                    Navigator.pop(context);
                  }
                  setState(() {
                    isAddingAdmin = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                child: isAddingAdmin
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addAdmin(String name, String phone) async {
    context.loaderOverlay.show();
    try {
      final adminRef = _firestore.collection('admins').doc(phone);
      final adminSnapshot = await adminRef.get();

      if (adminSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Admin with this number already exists!")),
        );
        return;
      }

      await adminRef.set({
        'firstName': name,
        'mobile': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin added successfully!")),
      );
      context.loaderOverlay.show();
    } catch (e) {
      print("Error adding admin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding admin.")),
      );
    }
  }
}
