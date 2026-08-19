import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/transaction_model.dart';
import '../service/transaction_service.dart';

class TransactionHistoryController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    // Load instantly from memory cache if present (0 DB calls!)
    final cached = TransactionService.cachedTransactions;
    if (cached.isNotEmpty) {
      transactions.assignAll(cached);
      isLoading.value = false;
      debugPrint('⚡ [TransactionHistoryController] Loaded ${cached.length} transactions from memory cache (0 DB calls).');
    } else {
      isLoading.value = true;
    }

    try {
      final data = await TransactionService.fetchUserTransactions(uid);
      transactions.assignAll(data);
      debugPrint(
        '🔥 [TransactionHistoryController] Loaded ${data.length} transactions from Firestore.',
      );
    } catch (error) {
      debugPrint(
        '❌ [TransactionHistoryController] Fetch error: $error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes transaction data manually (e.g., via Pull-to-Refresh)
  Future<void> refreshTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final updated = await TransactionService.fetchUserTransactions(
      uid,
      forceRefresh: true,
    );
    transactions.assignAll(updated);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      // 1. Filter by status chip
      if (selectedFilter.value == 'Completed' && !tx.isCompleted) {
        return false;
      }
      if (selectedFilter.value == 'Pending' && !tx.isPending) {
        return false;
      }

      // 2. Filter by search query
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matchSalon = tx.salonName.toLowerCase().contains(q);
        final matchId = tx.transactionId.toLowerCase().contains(q);
        final matchBooking = tx.bookingId.toLowerCase().contains(q);
        final matchMethod = tx.paymentMethod.toLowerCase().contains(q);
        final matchAmount = tx.amount.toString().contains(q);

        if (!matchSalon && !matchId && !matchBooking && !matchMethod && !matchAmount) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  double get totalSpent {
    double total = 0;
    for (var tx in transactions) {
      if (tx.isCompleted) {
        total += tx.amount;
      }
    }
    return total;
  }

  int get totalCount => transactions.length;

  int get completedCount => transactions.where((tx) => tx.isCompleted).length;

  int get pendingCount => transactions.where((tx) => tx.isPending).length;
}
