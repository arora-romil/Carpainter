import 'package:carpainter/screens/admin/carpenterdetailsScreen.dart';
import 'package:carpainter/screens/admin/profileRequestScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarpenterListScreen extends StatefulWidget {
  const CarpenterListScreen({super.key});

  @override
  State<CarpenterListScreen> createState() => _CarpenterListScreenState();
}

class _CarpenterListScreenState extends State<CarpenterListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _navigateToDetails(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarpenterDetailScreen(data: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight:
            MediaQuery.of(context).size.height * 0.22, // Fix height issue
        backgroundColor: const Color(0xFF493628),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        title: Column(
          children: [
            const Icon(Icons.handyman, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            const Text(
              "Carpenters",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSearchBar(), // Move search bar inside AppBar
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'carpenter')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.brown));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No carpenters found"));
          }

          // Filter carpenters locally after fetching
          final carpenters = snapshot.data!.docs.where((doc) {
            var firstName = doc['firstName'].toString().toLowerCase();
            return _searchQuery.isEmpty || firstName.contains(_searchQuery);
          }).toList();

          if (carpenters.isEmpty) {
            return const Center(child: Text("No carpenters found"));
          }

          return ListView.builder(
            itemCount: carpenters.length,
            itemBuilder: (context, index) {
              var doc = carpenters[index];
              var firstName = doc['firstName'];
              var lastName = doc['lastName'];
              var mobile = doc['mobile'];
              var points = doc['points'];
              var state = doc['state'];
              var profileImage =
                  (doc.data() as Map<String, dynamic>)["photoUrl"] ?? '';

              return GestureDetector(
                onTap: () => _navigateToDetails(context, doc),
                child: _buildCard(
                  name: "$firstName $lastName",
                  mobile: mobile,
                  points: points,
                  state: state,
                  profileImage: profileImage,
                  cardColor: const Color(0xFFAB886D),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF493628),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileRequestScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search by first name...",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.black54),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCard({
    required String name,
    required String mobile,
    required int points,
    required String state,
    required String profileImage,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: profileImage.isNotEmpty ? profileImage : name,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
              child: profileImage.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Colors.black45)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "State: $state",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Mobile: $mobile",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Points: $points",
                      style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
