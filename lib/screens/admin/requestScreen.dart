import 'package:carpainter/screens/auth/phoneNumber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false; // State variable to track loading status
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout();
        },
        backgroundColor: const Color(0xFFAB886D),
        child: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF493628),
              borderRadius: BorderRadius.only(
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
                children: const [
                  Icon(
                    Icons.request_page,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pending Requests",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Approve or reject pending requests",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('requests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.brown));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No pending requests."));
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final uid = request['uid']; // UID of the user
                  final redeemPoints = request['redeemPoints'];
                  final time = (request['createdAt'] as Timestamp).toDate();
                  final formattedTime = DateFormat('hh:mm:ss a').format(time);

                  return Card(
                    shadowColor: Colors.black,
                    elevation: 10,
                    color: const Color(0xFFAB886D),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future:
                                _firestore.collection('users').doc(uid).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.brown));
                              }
                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const Text("User data not found.");
                              }

                              final user = userSnapshot.data!;
                              final userName =
                                  "${user['firstName']} ${user['lastName']}";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name: $userName",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Redeem Points: $redeemPoints",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Request Time: ${time.day}/${time.month}/${time.year} $formattedTime"),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null // Disable button when loading
                                            : () async {
                                                setState(() {
                                                  _isLoading =
                                                      true; // Start loading
                                                });
                                                await _approveRequest(
                                                    request.id,
                                                    uid,
                                                    redeemPoints);
                                                setState(() {
                                                  _isLoading =
                                                      false; // Stop loading
                                                });
                                              },
                                        icon: const Icon(Icons.check,
                                            color: Colors.white),
                                        label: const Text(
                                          "Approve",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Global loader during the approval process
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.brown,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(
      String requestId, String uid, int redeemPoints) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // References
        final requestRef = _firestore.collection('requests').doc(requestId);
        final userRef = _firestore.collection('users').doc(uid);
        final adminStatsRef =
            _firestore.collection('adminStats').doc('redeemedPoints');

        // Read user document
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User not found!");
        }

        final currentPoints = userSnapshot['points'];

        // Ensure the user has enough points
        if (currentPoints < redeemPoints) {
          throw Exception("Insufficient points!");
        }

        // Read admin stats for redeemed points
        final adminStatsSnapshot = await transaction.get(adminStatsRef);

        // Get the current total redeemed points (default to 0 if not found)
        int totalRedeemedPoints = 0;
        if (adminStatsSnapshot.exists) {
          totalRedeemedPoints = adminStatsSnapshot['totalRedeemedPoints'] ?? 0;
        }

        // Perform all writes after reads
        transaction.update(
            requestRef, {'status': 'approved'}); // Update request status
        transaction.update(userRef,
            {'points': currentPoints - redeemPoints}); // Deduct user points
        transaction.update(userRef, {'pointsRedeemed': redeemPoints});

        // Update total redeemed points in admin stats
        transaction.set(
          adminStatsRef,
          {'totalRedeemedPoints': totalRedeemedPoints + redeemPoints},
          SetOptions(merge: true), // Merge with existing data
        );
        addPointEntry(uid, redeemPoints, "Redeemed");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request approved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> addPointEntry(String uid, int points, String reason) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('points_history')
        .add({
      'points': points,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
