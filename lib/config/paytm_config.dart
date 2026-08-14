// lib/config/paytm_config.dart

/// Environment Configuration for Paytm Payment Gateway.
///
/// Simply toggle [isStaging] between `true` (Test Mode) and `false` (Production/Main Mode).
/// When you switch [isStaging] or change key variables, all endpoints,
/// Website IDs, Merchant IDs, and SDK flags update automatically.
class PaytmConfig {
  PaytmConfig._();

  // ───────────────────────────────────────────────────────────────────────────
  // 🔘 ENVIRONMENT TOGGLE SWITCH
  // Currently set to `true` to force Staging/Test key usage.
  // ───────────────────────────────────────────────────────────────────────────
  static const bool isStaging = true;

  // ─── TEST / STAGING CONFIG ────────────────────────────────────────────────
  static const String _testMid = 'BWJTuN52369870807612';
  static const String _testMerchantKey = 'WyQzXGnobkDeLOJc';
  static const String _testWebsite = 'WEBSTAGING';

  // ─── PRODUCTION / MAIN CONFIG (COMMENTED OUT FOR NOW) ─────────────────────
  // static const String _prodMid = 'TalkEn72814503800002';
  // static const String _prodMerchantKey = 'S1KYYIaCx0qZ71OI';
  // static const String _prodWebsite = 'DEFAULT';

  // ─── DYNAMIC GETTERS (AUTO SWITCHED) ──────────────────────────────────────
  /// Active Merchant ID based on environment mode.
  static String get mid => isStaging ? _testMid : _testMid;

  /// Active Merchant Key based on environment mode.
  static String get merchantKey => isStaging ? _testMerchantKey : _testMerchantKey;

  /// Active Website Name based on environment mode.
  static String get website => isStaging ? _testWebsite : _testWebsite;

  /// Gets the Paytm initiateTransaction API endpoint for an order.
  static String getInitiateUrl(String orderId) {
    return isStaging
        ? 'https://securestage.paytmpayments.com/theia/api/v1/initiateTransaction?mid=$mid&orderId=$orderId'
        : 'https://secure.paytmpayments.com/theia/api/v1/initiateTransaction?mid=$mid&orderId=$orderId';
  }

  /// Gets the Paytm callback URL for an order.
  static String getCallbackUrl(String orderId) {
    return isStaging
        ? 'https://securestage.paytmpayments.com/theia/paytmCallback?ORDER_ID=$orderId'
        : 'https://secure.paytmpayments.com/theia/paytmCallback?ORDER_ID=$orderId';
  }
}
