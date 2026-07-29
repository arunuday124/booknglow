import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a service item inside the `services` array of a Salon document in Firestore.
class SalonServiceItem {
  final String catagory;
  final String duration;
  final dynamic price; // int or String
  final String salonId;
  final String serviceName;

  SalonServiceItem({
    required this.catagory,
    required this.duration,
    required this.price,
    required this.salonId,
    required this.serviceName,
  });

  factory SalonServiceItem.fromMap(Map<String, dynamic> map) {
    return SalonServiceItem(
      catagory: map['catagory'] as String? ?? map['category'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      price: map['price'] ?? 0,
      salonId: map['salonId'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catagory': catagory,
      'duration': duration,
      'price': price,
      'salonId': salonId,
      'serviceName': serviceName,
    };
  }
}

/// Represents a document in the Firestore `salons` collection.
class SalonModel {
  final String salonId;
  final String salonName;
  final String address;
  final List<String> categories;
  final String openingHours;
  final String closingHours;
  final String ownerName;
  final String phone;
  final double ratings;
  final int reviews;
  final String shopImage;
  final GeoPoint location;
  final Timestamp createdAt;
  final List<SalonServiceItem> services;

  SalonModel({
    required this.salonId,
    required this.salonName,
    required this.address,
    required this.categories,
    required this.openingHours,
    required this.closingHours,
    required this.ownerName,
    required this.phone,
    required this.ratings,
    required this.reviews,
    required this.shopImage,
    required this.location,
    required this.createdAt,
    required this.services,
  });

  /// Factory constructor to parse Firestore document snapshot safely.
  factory SalonModel.fromMap(String docId, Map<String, dynamic> map) {
    List<String> parsedCategories = [];
    if (map['categories'] is List) {
      parsedCategories = (map['categories'] as List).map((e) => e.toString()).toList();
    }

    List<SalonServiceItem> parsedServices = [];
    if (map['services'] is List) {
      parsedServices = (map['services'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => SalonServiceItem.fromMap(s))
          .toList();
    }

    final phoneVal = map['phone']?.toString() ?? '';

    return SalonModel(
      salonId: (map['salonId'] as String?)?.isNotEmpty == true ? map['salonId'] as String : docId,
      salonName: map['salonName'] as String? ?? map['name'] as String? ?? 'Salon',
      address: map['address'] as String? ?? map['location'] as String? ?? '',
      categories: parsedCategories,
      openingHours: map['openingHours'] as String? ?? '10 AM',
      closingHours: map['closingHours'] as String? ?? '8 PM',
      ownerName: map['ownerName'] as String? ?? '',
      phone: phoneVal,
      ratings: (map['ratings'] as num?)?.toDouble() ?? (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviews: (map['reviews'] as num?)?.toInt() ?? 0,
      shopImage: map['shopImage'] as String? ?? map['image'] as String? ?? '',
      location: map['location'] is GeoPoint ? map['location'] as GeoPoint : const GeoPoint(0, 0),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      services: parsedServices,
    );
  }

  /// Converts model to Map containing both Firestore schema and UI display helper keys.
  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'salonName': salonName,
      'name': salonName,
      'address': address,
      'location': address,
      'categories': categories,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'ownerName': ownerName,
      'phone': phone,
      'ratings': ratings,
      'rating': '$ratings',
      'reviews': '$reviews reviews',
      'shopImage': shopImage,
      'image': shopImage,
      'price': '',
      'isOpen': true,
      'services': services.map((s) => s.toMap()).toList(),
    };
  }
}
