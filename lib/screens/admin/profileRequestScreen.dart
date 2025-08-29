import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileRequestScreen extends StatefulWidget {
  const ProfileRequestScreen({super.key});

  @override
  _ProfileRequestScreenState createState() => _ProfileRequestScreenState();
}

class _ProfileRequestScreenState extends State<ProfileRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false; // State variable to track loading status

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth < 600 ? 180 : 220),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color(0xFF493628),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: screenWidth < 600 ? 24.0 : 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.request_page,
                    size: screenWidth < 600 ? 50 : 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pending Requests",
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 26 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Approve or reject pending requests",
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 20 : 24,
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
                .collection('users')
                .where('profileRequest', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
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
                  final fname = request['firstName'];
                  final lname = request['lastName'];
                  final time = (request['createdAt'] as Timestamp).toDate();
                  final mobile = request['mobile'];
                  final locality = request['locality'];
                  var profileImage =
                      (request.data() as Map<String, dynamic>)["photoUrl"] ??
                          '';

                  final docId = request.id;
                  final formattedTime = DateFormat('hh:mm:ss a').format(time);

                  return Card(
                    shadowColor: Colors.black,
                    elevation: 10,
                    color: Color(0xFFAB886D),
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profileImage),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                // This will ensure that the text takes up remaining space and doesn't cause overflow
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$fname $lname",
                                      style: TextStyle(
                                        fontSize: screenWidth < 600 ? 18 : 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Prevents overflow if the text is too long
                                    ),
                                    SizedBox(height: 8),
                                    Text("Mobile: $mobile"),
                                    SizedBox(height: 8),
                                    Text("Locality: $locality"),
                                    SizedBox(height: 8),
                                    Text(
                                      "Request Time: ${time.day}/${time.month}/${time.year} $formattedTime",
                                      overflow: TextOverflow
                                          .ellipsis, // Prevents overflow
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await _approveProfileRequest(docId);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                icon: Icon(Icons.check, color: Colors.white),
                                label: Text(
                                  "Approve",
                                  style: TextStyle(
                                      fontSize: screenWidth < 600 ? 16 : 18,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth < 600 ? 16 : 24,
                                    vertical: screenWidth < 600 ? 10 : 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.brown,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _approveProfileRequest(String docId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(docId);
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User not found!");
        }

        transaction.update(userRef, {'profileRequest': 'approved'});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile request approved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
