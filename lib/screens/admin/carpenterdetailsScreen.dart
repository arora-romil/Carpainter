import 'package:carpainter/screens/carpenter/pointsHistory.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CarpenterDetailScreen extends StatefulWidget {
  DocumentSnapshot data;

  CarpenterDetailScreen({super.key, required this.data});

  @override
  _CarpenterDetailScreenState createState() => _CarpenterDetailScreenState();
}

class _CarpenterDetailScreenState extends State<CarpenterDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _pointsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var data = widget.data.data() as Map<String, dynamic>;

    return LoaderOverlay(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "Carpenter Details",
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
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Hero(
                      tag: widget.data.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          elevation: 8,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(data['photoUrl'] ?? ''),
                                      backgroundColor: Colors.grey[200],
                                      child: data['photoUrl'] == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.black45,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      "${data['firstName']} ${data['lastName']}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF493628),
                                      ),
                                    ),
                                  ),
                                  Divider(thickness: 2),
                                  const SizedBox(height: 24),
                                  _buildDetailsSection(data),
                                  const SizedBox(height: 24),
                                  TextField(
                                    controller: _pointsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Enter points to assign',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 6, // Adds space between buttons
                                    children: [
                                      ElevatedButton(
                                        onPressed: _assignPoints,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF493628),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        child: const Text("Assign Points",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PointsHistoryScreen(
                                                      userId: widget.data.id),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF493628),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.history,
                                            color: Colors.white),
                                        label: const Text("Points History",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> data) {
    return Column(
      children: [
        _detailRow("Mobile", data['mobile']),
        _detailRow("WhatsApp", data['whatsapp']),
        _detailRow("Aadhaar", data['aadhaar']),
        _detailRow("Pincode", data['pincode']),
        _detailRow("State", data['state']),
        _detailRow("City", data['city']),
        _detailRow("Locality", data['locality']),
        _detailRow("Points", data['points'].toString()),
      ],
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _assignPoints() async {
    final int pointsToAdd = int.tryParse(_pointsController.text) ?? 0;

    if (pointsToAdd > 0) {
      context.loaderOverlay.show();

      try {
        final docRef = _firestore.collection('users').doc(widget.data.id);

        // Atomically update points
        await docRef.update({
          'points': FieldValue.increment(pointsToAdd),
        });

        addPointEntry(widget.data.id, pointsToAdd, 'Admin Assigned Points');

        // Fetch updated document
        final updatedDoc = await docRef.get();

        // Update UI
        setState(() {
          widget.data = updatedDoc;
          _pointsController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Points assigned successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error assigning points: $e")),
        );
      } finally {
        context.loaderOverlay.hide();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid point value.")),
      );
    }
  }

  Future<void> addPointEntry(
      String carpenterId, int points, String reason) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.data.id)
        .collection('points_history')
        .add({
      'points': points,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
