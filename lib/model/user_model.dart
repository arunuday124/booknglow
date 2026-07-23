import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a document in the Firestore "user" collection.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final int phone;
  final String profileImages;
  final String pushToken;
  final Timestamp lastLogin;
  final Timestamp createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImages,
    required this.pushToken,
    required this.lastLogin,
    required this.createdAt,
  });

  /// Converts the model to a plain Map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImages': profileImages,
      'pushToken': pushToken,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: (map['phone'] as num?)?.toInt() ?? 0,
      profileImages: map['profileImages'] as String? ?? '',
      pushToken: map['pushToken'] as String? ?? '',
      lastLogin: map['lastLogin'] as Timestamp? ?? Timestamp.now(),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Creates a copy of this [UserModel] with specified fields replaced.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? phone,
    String? profileImages,
    String? pushToken,
    Timestamp? lastLogin,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImages: profileImages ?? this.profileImages,
      pushToken: pushToken ?? this.pushToken,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
