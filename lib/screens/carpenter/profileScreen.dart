import 'dart:io';
import 'package:carpainter/screens/auth/phoneNumber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController firstNameController,
      lastNameController,
      whatsappController,
      mobileController,
      aadhaarController,
      pincodeController,
      stateController,
      cityController,
      localityController;

  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserData();
  }

  void _initializeControllers() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    whatsappController = TextEditingController();
    mobileController = TextEditingController();
    aadhaarController = TextEditingController();
    pincodeController = TextEditingController();
    stateController = TextEditingController();
    cityController = TextEditingController();
    localityController = TextEditingController();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            firstNameController.text = userDoc['firstName'];
            lastNameController.text = userDoc['lastName'];
            whatsappController.text = userDoc['whatsapp'];
            mobileController.text = userDoc['mobile'];
            aadhaarController.text = userDoc['aadhaar'];
            pincodeController.text = userDoc['pincode'];
            stateController.text = userDoc['state'];
            cityController.text = userDoc['city'];
            localityController.text = userDoc['locality'];
            photoUrl = userDoc.data().toString().contains('photoUrl')
                ? userDoc['photoUrl']
                : null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      File imageFile = File(pickedFile.path);
      String userId = _auth.currentUser!.uid;
      TaskSnapshot snapshot =
          await _storage.ref('profile_images/$userId.jpg').putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
      });

      setState(() {
        photoUrl = downloadUrl;
        _isUploading = false;
      });
    } catch (e) {
      print("Error uploading image: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      String userId = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(userId).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'whatsapp': whatsappController.text,
        'mobile': mobileController.text,
        'aadhaar': aadhaarController.text,
        'pincode': pincodeController.text,
        'state': stateController.text,
        'city': cityController.text,
        'locality': localityController.text,
      });

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PhoneNumberScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF493628), Color(0xFFA8653B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "View and edit your profile",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit,
                  color: Colors.white),
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF493628)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (photoUrl != null && photoUrl!.isNotEmpty)
                                  ? NetworkImage(photoUrl!)
                                  : null,
                          child: (photoUrl == null || photoUrl!.isEmpty)
                              ? Icon(Icons.person,
                                  size: 60, color: Colors.black45)
                              : null,
                        ),
                        if (_isUploading)
                          CircularProgressIndicator(color: Colors.white),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadProfileImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.brown,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 2),
                  _buildProfileField("First Name", firstNameController),
                  _buildProfileField("Last Name", lastNameController),
                  _buildProfileField("Whatsapp", whatsappController),
                  _buildProfileField("Mobile", mobileController),
                  _buildProfileField("Aadhaar", aadhaarController),
                  Divider(thickness: 2),
                  _buildProfileField("Pincode", pincodeController),
                  _buildProfileField("State", stateController),
                  _buildProfileField("City", cityController),
                  _buildProfileField("Locality", localityController),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.brown),
                    label:
                        Text("Logout", style: TextStyle(color: Colors.brown)),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
