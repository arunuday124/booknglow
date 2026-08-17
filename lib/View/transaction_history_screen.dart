import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/transaction_history_controller.dart';
import '../model/transaction_model.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const _deepGreen = Color(0xFF05352F);
  static const _cream = Color(0xFFFAF9F5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _deepGreen,
          ),
        ),
        title: Text(
          "Transaction History",
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _deepGreen,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Card & Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  _SummaryCard(controller: controller),
                  const SizedBox(height: 16),
                  _FilterBar(controller: controller),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Firestore ListView showing transactions with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                color: _deepGreen,
                backgroundColor: Colors.white,
                onRefresh: () => controller.refreshTransactions(),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const _TransactionLoadingSkeleton();
                  }

                  final list = controller.filteredTransactions;
                  if (list.isEmpty) {
                    return _EmptyTransactionWidget(
                      filter: controller.selectedFilter.value,
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 8.0,
                      bottom: 32.0,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      return _TransactionTile(transaction: tx);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary Header Card Widget (StatelessWidget)
class _SummaryCard extends StatelessWidget {
  final TransactionHistoryController controller;

  const _SummaryCard({required this.controller});

  static const _deepGreen = Color(0xFF05352F);
  static const _lightGold = Color(0xFFE8D5AF);
  static const _goldBg = Color(0xFFFAF6EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _deepGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(5, 53, 47, 0.15),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        final totalSpent = controller.totalSpent;
        final totalCount = controller.totalCount;
        final completedCount = controller.completedCount;
        final pendingCount = controller.pendingCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _goldBg.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _lightGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "TOTAL SPENT",
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _lightGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$totalCount Transactions",
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Big Total Amount
            Text(
              "₹${totalSpent.toStringAsFixed(totalSpent.truncateToDouble() == totalSpent ? 0 : 2)}",
              style: GoogleFonts.playfairDisplay(
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color.fromRGBO(255, 255, 255, 0.15), height: 1),
            const SizedBox(height: 14),

            // Quick Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  label: "Completed",
                  value: "$completedCount",
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF81C784),
                ),
                _buildStatItem(
                  label: "Pending",
                  value: "$pendingCount",
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFFFFB74D),
                ),
                _buildStatItem(
                  label: "Payment Vault",
                  value: "Active",
                  icon: Icons.verified_user_outlined,
                  color: _lightGold,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Filter Bar Widget (StatelessWidget)
class _FilterBar extends StatelessWidget {
  final TransactionHistoryController controller;

  const _FilterBar({required this.controller});

  static const _deepGreen = Color(0xFF05352F);
  static const _lightGold = Color(0xFFE8D5AF);

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Completed', 'Pending'];

    return Obx(() {
      final currentFilter = controller.selectedFilter.value;

      return Row(
        children: filters.map((filter) {
          final isSelected = currentFilter == filter;
          int count = 0;
          if (filter == 'All') count = controller.totalCount;
          if (filter == 'Completed') count = controller.completedCount;
          if (filter == 'Pending') count = controller.pendingCount;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => controller.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _deepGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _deepGreen : _lightGold.withAlpha(150),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _deepGreen.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : _deepGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withAlpha(40)
                            : const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$count",
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF9E7E45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

/// Transaction Item Tile Widget (StatelessWidget)
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _lightGold = Color(0xFFE8D5AF);
  static const _goldBg = Color(0xFFFAF6EE);
  static const _cardBg = Colors.white;
  static const _mutedTeal = Color(0xFF7A8D87);
  static const _successGreen = Color(0xFF2E7D32);
  static const _pendingAmber = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    final isCompleted = transaction.isCompleted;
    final statusText = isCompleted
        ? "Completed"
        : (transaction.isPending ? "Pending Cash" : transaction.paymentStatus);

    final statusColor = isCompleted
        ? _successGreen
        : (transaction.isPending ? _pendingAmber : Colors.red.shade700);

    final statusBg = isCompleted
        ? const Color(0xFFE8F5E9)
        : (transaction.isPending ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE));

    IconData paymentIcon = Icons.payment_rounded;
    final methodLower = transaction.paymentMethod.toLowerCase();
    if (methodLower.contains('cash')) {
      paymentIcon = Icons.payments_outlined;
    } else if (methodLower.contains('upi') || methodLower.contains('gpay')) {
      paymentIcon = Icons.qr_code_scanner_rounded;
    } else if (methodLower.contains('card')) {
      paymentIcon = Icons.credit_card_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showReceiptModal(context, transaction),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Payment Method Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _goldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lightGold.withAlpha(128)),
                  ),
                  child: Icon(
                    paymentIcon,
                    color: _gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Main Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _deepGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: _mutedTeal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(transaction.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  color: _mutedTeal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            paymentIcon,
                            size: 11,
                            color: _mutedTeal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.paymentMethod,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _mutedTeal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount & Status Badge Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${transaction.amount.toStringAsFixed(transaction.amount.truncateToDouble() == transaction.amount ? 0 : 2)}",
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _deepGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return "Recent";
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$day $month ${date.year}, $hour:$minute $period";
  }

  static void _showReceiptModal(BuildContext context, TransactionModel tx) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Grab Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Success Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tx.isCompleted
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_top_rounded,
                  color: tx.isCompleted ? _successGreen : _pendingAmber,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                tx.isCompleted ? "Payment Successful" : "Payment Pending",
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _deepGreen,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${tx.amount.toStringAsFixed(tx.amount.truncateToDouble() == tx.amount ? 0 : 2)}",
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _deepGreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(color: Color(0xFFFAF9F5), height: 1),
              const SizedBox(height: 16),

              // Detail Rows
              _buildDetailRow("Salon", tx.salonName),
              _buildDetailRow("Date & Time", _formatDate(tx.createdAt)),
              _buildDetailRow("Payment Method", tx.paymentMethod),
              _buildDetailRow("Status", tx.paymentStatus.toUpperCase()),
              if (tx.bookingId.isNotEmpty)
                _buildDetailRow("Booking Reference", tx.bookingId),
              _buildDetailRow("Transaction ID", tx.transactionId, isCopyable: true),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "DONE",
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildDetailRow(String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              textStyle: const TextStyle(
                fontSize: 12,
                color: _mutedTeal,
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _deepGreen,
                      ),
                    ),
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        'Copied',
                        'Transaction ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _deepGreen,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: _gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty Transactions Widget (StatelessWidget)
class _EmptyTransactionWidget extends StatelessWidget {
  final String filter;

  const _EmptyTransactionWidget({required this.filter});

  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _goldBg = Color(0xFFFAF6EE);
  static const _mutedTeal = Color(0xFF7A8D87);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: _goldBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: _gold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    filter == 'All'
                        ? "No Transactions Yet"
                        : "No $filter Transactions",
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _deepGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter == 'All'
                        ? "When you book salon services, your payment history and receipt receipts will appear right here."
                        : "You currently have no transactions matching the '$filter' filter status.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: _mutedTeal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading Skeleton Placeholder Widget (StatelessWidget)
class _TransactionLoadingSkeleton extends StatelessWidget {
  const _TransactionLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
