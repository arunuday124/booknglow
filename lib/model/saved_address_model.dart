import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a document in the Firestore `user/{uid}/savedAddress` subcollection.
class SavedAddressModel {
  final String? id; // Firestore document ID
  final String address;
  final String building;
  final Timestamp createdAt;
  final String floor;
  final String houseNo;
  final bool isFavorite;
  final bool isSelected;
  final String landmark;
  final GeoPoint location;
  final String locationName;
  final String name;
  final String type;
  final Timestamp updatedAt;

  const SavedAddressModel({
    this.id,
    required this.address,
    required this.building,
    required this.createdAt,
    required this.floor,
    required this.houseNo,
    required this.isFavorite,
    required this.isSelected,
    required this.landmark,
    required this.location,
    required this.locationName,
    required this.name,
    required this.type,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'building': building,
      'createdAt': createdAt,
      'floor': floor,
      'houseNo': houseNo,
      'isFavorite': isFavorite,
      'isSelected': isSelected,
      'landmark': landmark,
      'location': location,
      'locationName': locationName,
      'name': name,
      'type': type,
      'updatedAt': updatedAt,
    };
  }

  factory SavedAddressModel.fromMap(String docId, Map<String, dynamic> map) {
    return SavedAddressModel(
      id: docId,
      address: map['address'] as String? ?? '',
      building: map['building'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      floor: map['floor'] as String? ?? '',
      houseNo: map['houseNo'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      isSelected: map['isSelected'] as bool? ?? false,
      landmark: map['landmark'] as String? ?? '',
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      locationName: map['locationName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'Other',
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  SavedAddressModel copyWith({
    String? id,
    String? address,
    String? building,
    Timestamp? createdAt,
    String? floor,
    String? houseNo,
    bool? isFavorite,
    bool? isSelected,
    String? landmark,
    GeoPoint? location,
    String? locationName,
    String? name,
    String? type,
    Timestamp? updatedAt,
  }) {
    return SavedAddressModel(
      id: id ?? this.id,
      address: address ?? this.address,
      building: building ?? this.building,
      createdAt: createdAt ?? this.createdAt,
      floor: floor ?? this.floor,
      houseNo: houseNo ?? this.houseNo,
      isFavorite: isFavorite ?? this.isFavorite,
      isSelected: isSelected ?? this.isSelected,
      landmark: landmark ?? this.landmark,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      name: name ?? this.name,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
