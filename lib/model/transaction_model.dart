import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String bookingId;
  final String salonId;
  final String salonName;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String userId;
  final String userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.transactionId,
    required this.bookingId,
    required this.salonId,
    required this.salonName,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.userId,
    required this.userName,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return TransactionModel(
      transactionId: (map['transactionId'] as String?) ?? docId,
      bookingId: (map['bookingId'] as String?) ?? '',
      salonId: (map['salonId'] as String?) ?? '',
      salonName: (map['salonName'] as String?) ?? 'Book\'N\'Glow Salon',
      amount: parseAmount(map['amount']),
      paymentMethod: (map['paymentMethod'] as String?) ?? 'Cash',
      paymentStatus: (map['paymentStatus'] as String?) ?? 'completed',
      userId: (map['userId'] as String?) ?? '',
      userName: (map['userName'] as String?) ?? 'Valued Customer',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TransactionModel.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'bookingId': bookingId,
      'salonId': salonId,
      'salonName': salonName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => paymentStatus.toLowerCase().trim() == 'completed';
  bool get isPending => paymentStatus.toLowerCase().trim() == 'pending';
  bool get isFailed => paymentStatus.toLowerCase().trim() == 'failed';
}
