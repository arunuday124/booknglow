import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/transaction_model.dart';

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
      clearCache();

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
        clearCache();
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
        clearCache();
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

  static final List<TransactionModel> _cachedTransactions = [];
  static bool _hasFetchedInitial = false;

  /// Gets unmodifiable list of cached transactions
  static List<TransactionModel> get cachedTransactions => List.unmodifiable(_cachedTransactions);

  /// Clears in-memory cache
  static void clearCache() {
    _cachedTransactions.clear();
    _hasFetchedInitial = false;
  }

  /// Updates local memory cache from a list
  static void updateCache(List<TransactionModel> list) {
    _cachedTransactions.clear();
    _cachedTransactions.addAll(list);
    _hasFetchedInitial = true;
  }

  /// Returns a real-time stream of [TransactionModel] for a specific user ID.
  static Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _transactionsCol
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
      // Sort newest first
      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      updateCache(list);
      return list;
    });
  }

  /// Fetches transactions directly with optional forceRefresh
  static Future<List<TransactionModel>> fetchUserTransactions(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _hasFetchedInitial && _cachedTransactions.isNotEmpty) {
      debugPrint('⚡ [TransactionService] Returning ${_cachedTransactions.length} cached transactions (0 DB calls).');
      return List.from(_cachedTransactions);
    }

    try {
      debugPrint('🔥 [TransactionService] Fetching user transactions from Firestore DB...');
      final snapshot = await _transactionsCol.where('userId', isEqualTo: userId).get();
      final list = snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      updateCache(list);
      return list;
    } catch (e) {
      debugPrint('❌ [TransactionService] Error fetching user transactions: $e');
      return _cachedTransactions;
    }
  }
}

