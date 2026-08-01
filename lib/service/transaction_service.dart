import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Handles Firestore operations for the `transactions` collection.
class TransactionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reference to the `transactions` collection.
  static CollectionReference<Map<String, dynamic>> get _transactionsCol =>
      _db.collection('transactions');

  /// Creates a new transaction document in the `transactions` collection.
  ///
  /// Attributes:
  /// - `amount`: int64 (integer)
  /// - `bookingId`: String
  /// - `createdAt`: String (ISO 8601 timestamp string)
  /// - `paymentMethod`: String
  /// - `paymentStatus`: String ("pending" for cash, "completed" for online)
  /// - `salonId`: String
  /// - `salonName`: String
  /// - `transactionId`: String (Document ID)
  /// - `updatedAt`: String (ISO 8601 timestamp string)
  /// - `userId`: String
  /// - `userName`: String
  static Future<String?> createTransaction({
    required String bookingId,
    required String salonId,
    required String salonName,
    required int amount,
    required String paymentMethod,
    required String userId,
    required String userName,
  }) async {
    try {
      final docRef = _transactionsCol.doc();
      final isCash = paymentMethod.toLowerCase().trim().contains('cash');
      final initialStatus = isCash ? 'pending' : 'completed';
      final nowIso = DateTime.now().toIso8601String();

      final transactionData = <String, dynamic>{
        'amount': amount,
        'bookingId': bookingId,
        'createdAt': nowIso,
        'paymentMethod': paymentMethod,
        'paymentStatus': initialStatus,
        'salonId': salonId,
        'salonName': salonName,
        'transactionId': docRef.id,
        'updatedAt': nowIso,
        'userId': userId,
        'userName': userName,
      };

      debugPrint(
        '🔥 [TransactionService] Writing transaction to Firestore: $transactionData',
      );
      await docRef.set(transactionData);
      debugPrint(
        '✅ [TransactionService] Transaction document created with ID: ${docRef.id}',
      );

      return docRef.id;
    } catch (e, stack) {
      debugPrint(
        '❌ [TransactionService] ERROR creating transaction: $e\n$stack',
      );
      return null;
    }
  }

  /// Updates the `paymentStatus` to `"completed"` and `updatedAt` to current ISO string
  /// for a given transaction document ID or booking ID.
  static Future<bool> markPaymentAsComplete({
    String? transactionId,
    String? bookingId,
  }) async {
    try {
      final nowIso = DateTime.now().toIso8601String();

      if (transactionId != null && transactionId.isNotEmpty) {
        await _transactionsCol.doc(transactionId).update({
          'paymentStatus': 'completed',
          'updatedAt': nowIso,
        });
        debugPrint(
          '✅ [TransactionService] Payment status updated to completed for transaction ID: $transactionId',
        );
        return true;
      } else if (bookingId != null && bookingId.isNotEmpty) {
        final querySnapshot = await _transactionsCol
            .where('bookingId', isEqualTo: bookingId)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'paymentStatus': 'completed',
            'updatedAt': nowIso,
          });
        }
        debugPrint(
          '✅ [TransactionService] Payment status updated to completed for booking ID: $bookingId',
        );
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint(
        '❌ [TransactionService] ERROR updating payment status: $e\n$stack',
      );
      return false;
    }
  }

  /// Fetches transaction detail for a given booking ID.
  static Future<Map<String, dynamic>?> getTransactionByBookingId(
    String bookingId,
  ) async {
    try {
      final querySnapshot = await _transactionsCol
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['transactionId'] = doc.id;
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ [TransactionService] Error fetching transaction: $e');
    }
    return null;
  }
}
