// lib/service/paytm_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';
import '../config/paytm_config.dart';
import '../paytm_checksum.dart';

/// Result object encapsulating Paytm transaction outcomes.
class PaytmTransactionResult {
  final bool isSuccess;
  final String status;
  final String message;
  final String orderId;
  final String? txnId;
  final Map<String, dynamic>? rawResponse;

  PaytmTransactionResult({
    required this.isSuccess,
    required this.status,
    required this.message,
    required this.orderId,
    this.txnId,
    this.rawResponse,
  });

  factory PaytmTransactionResult.failure(String orderId, String message) {
    return PaytmTransactionResult(
      isSuccess: false,
      status: 'TXN_FAILURE',
      message: message,
      orderId: orderId,
    );
  }
}

/// Service handling Paytm V2 Initiate Transaction API and AllInOne SDK execution.
class PaytmService {
  PaytmService._();

  static final PaytmPaymentsAllinonesdk _paytmSdk = PaytmPaymentsAllinonesdk();

  /// Step 1: Call Paytm Initiate Transaction API to obtain [txnToken].
  static Future<String> fetchTxnToken({
    required String orderId,
    required String amount,
    required String custId,
  }) async {
    final bodyMap = {
      'requestType': 'Payment',
      'mid': PaytmConfig.mid,
      'websiteName': PaytmConfig.website,
      'orderId': orderId,
      'callbackUrl': PaytmConfig.getCallbackUrl(orderId),
      'txnAmount': {'value': amount, 'currency': 'INR'},
      'userInfo': {'custId': custId},
    };

    final bodyStr = jsonEncode(bodyMap);
    final checksum = PaytmChecksum.generateSignature(
      bodyStr,
      PaytmConfig.merchantKey,
    );

    final url = PaytmConfig.getInitiateUrl(orderId);

    log('🔵 [PaytmService] Initiating Txn for Order: $orderId | Mid: ${PaytmConfig.mid} | Staging: ${PaytmConfig.isStaging}');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'head': {'signature': checksum},
        'body': bodyMap,
      }),
    );

    log('🟢 [PaytmService] Response status: ${response.statusCode}');
    log('🟢 [PaytmService] Response body: ${response.body}');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['body']?['txnToken'] as String?;

    if (token == null || token.isEmpty) {
      final errorMsg = json['body']?['resultInfo']?['resultMsg'] ??
          'Failed to obtain txnToken from Paytm';
      throw Exception(errorMsg);
    }

    return token;
  }

  /// Step 2: Full Paytm transaction flow (obtain token -> invoke SDK).
  static Future<PaytmTransactionResult> startPayment({
    required String orderId,
    required double amount,
    required String custMobile,
  }) async {
    final formattedAmount = amount.toStringAsFixed(2);
    final custId = 'CUST_${custMobile.replaceAll(RegExp(r'\D'), '')}';

    try {
      // 1. Fetch txnToken from Paytm servers
      final txnToken = await fetchTxnToken(
        orderId: orderId,
        amount: formattedAmount,
        custId: custId,
      );

      // 2. Start Paytm AllInOne SDK payment
      final callbackUrl = PaytmConfig.getCallbackUrl(orderId);
      final rawResult = await _paytmSdk.startTransaction(
        PaytmConfig.mid,
        orderId,
        formattedAmount,
        txnToken,
        callbackUrl,
        PaytmConfig.isStaging,
        false, // restrictAppInvoke
      );

      log('🟢 [PaytmService] SDK Response: $rawResult');

      if (rawResult == null) {
        return PaytmTransactionResult.failure(orderId, 'Transaction cancelled');
      }

      final Map<String, dynamic> result = Map<String, dynamic>.from(rawResult);
      final status = result['STATUS']?.toString() ?? 'CANCELLED';
      final msg = result['RESPMSG']?.toString() ?? 'Transaction completed with status: $status';
      final txnId = result['TXNID']?.toString();

      final isSuccess = status == 'TXN_SUCCESS';

      return PaytmTransactionResult(
        isSuccess: isSuccess,
        status: status,
        message: msg,
        orderId: orderId,
        txnId: txnId,
        rawResponse: result,
      );
    } on PlatformException catch (pe) {
      log('❌ [PaytmService] PlatformException: ${pe.message} | Details: ${pe.details}');
      final msg = pe.message ?? 'Platform error occurred during payment';
      return PaytmTransactionResult.failure(orderId, msg);
    } catch (e) {
      log('❌ [PaytmService] Exception: $e');
      return PaytmTransactionResult.failure(orderId, e.toString().replaceAll('Exception: ', ''));
    }
  }
}
