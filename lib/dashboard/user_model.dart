import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String firstName, lastName, whatsapp, mobile, aadhaar;
  final String pincode, state, district, city, address, role;
  final bool isAdmin;
  final int points, pointsRedeemed;
  final Timestamp createdAt;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.whatsapp,
    required this.mobile,
    required this.aadhaar,
    required this.pincode,
    required this.state,
    required this.district,
    required this.city,
    required this.address,
    required this.role,
    required this.isAdmin,
    required this.points,
    required this.pointsRedeemed,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return UserModel(
      firstName: data['firstName'],
      lastName: data['lastName'],
      whatsapp: data['whatsapp'],
      mobile: data['mobile'],
      aadhaar: data['aadhaar'],
      pincode: data['pincode'],
      state: data['state'],
      district: data['district'],
      city: data['city'],
      address: data['address'],
      role: data['role'],
      isAdmin: data['isAdmin'],
      points: data['points'] ?? 0,
      pointsRedeemed: data['pointsRedeemed'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
