import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/salon_model.dart';

/// Handles Firestore operations and pagination for the `salons` collection.
class SalonService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _salonsCol =>
      _db.collection('salons');

  // In-memory cache for salons to prevent duplicate DB calls when navigating pages
  static final List<SalonModel> _cachedSalons = [];
  static DocumentSnapshot? _lastDocument;
  static bool _hasMore = true;
  static bool _hasFetchedInitial = false;
  static bool _isLoadingMore = false;

  static List<SalonModel> get cachedSalons => List.unmodifiable(_cachedSalons);
  static bool get hasMore => _hasMore;
  static bool get hasFetchedInitial => _hasFetchedInitial;
  static bool get isLoadingMore => _isLoadingMore;

  /// Clears cache (e.g. on user logout or force pull-to-refresh)
  static void clearCache() {
    _cachedSalons.clear();
    _lastDocument = null;
    _hasMore = true;
    _hasFetchedInitial = false;
    _isLoadingMore = false;
  }

  /// Fetches the initial batch of 10 salons from Firestore.
  /// If already fetched in this session, returns cached copy without DB calls.
  static Future<List<SalonModel>> fetchInitialSalons({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasFetchedInitial && _cachedSalons.isNotEmpty) {
      debugPrint('⚡ [SalonService] Returning cached salons without DB call (${_cachedSalons.length} items).');
      return _cachedSalons;
    }

    try {
      debugPrint('🔥 [SalonService] Fetching initial 10 salons from Firestore...');
      final querySnapshot = await _salonsCol
          .orderBy('ratings', descending: true)
          .limit(10)
          .get();

      _cachedSalons.clear();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          _cachedSalons.add(SalonModel.fromMap(doc.id, doc.data()));
        }
        _lastDocument = querySnapshot.docs.last;
        _hasMore = querySnapshot.docs.length >= 10;
      } else {
        _hasMore = false;
      }

      _hasFetchedInitial = true;
      debugPrint('✅ [SalonService] Successfully loaded ${_cachedSalons.length} salons from Firestore.');
      return _cachedSalons;
    } catch (e, stack) {
      debugPrint('❌ [SalonService] ERROR fetching salons from Firestore: $e\n$stack');
      _hasFetchedInitial = true;
      return _cachedSalons;
    }
  }

  /// Fetches the next batch of 10 salons for lazy-loading pagination.
  static Future<List<SalonModel>> fetchMoreSalons() async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) {
      return _cachedSalons;
    }

    _isLoadingMore = true;
    try {
      debugPrint('🔥 [SalonService] Fetching next 10 salons starting after doc: ${_lastDocument!.id}');
      final querySnapshot = await _salonsCol
          .orderBy('ratings', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(10)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final salon = SalonModel.fromMap(doc.id, doc.data());
          if (!_cachedSalons.any((s) => s.salonId == salon.salonId)) {
            _cachedSalons.add(salon);
          }
        }
        _lastDocument = querySnapshot.docs.last;
        _hasMore = querySnapshot.docs.length >= 10;
      } else {
        _hasMore = false;
      }

      _isLoadingMore = false;
      debugPrint('✅ [SalonService] Total salons in cache after pagination: ${_cachedSalons.length}');
      return _cachedSalons;
    } catch (e, stack) {
      debugPrint('❌ [SalonService] ERROR loading more salons: $e\n$stack');
      _isLoadingMore = false;
      return _cachedSalons;
    }
  }

  /// Returns top 5 salons for dashboard.
  static List<SalonModel> getTop5Salons() {
    if (_cachedSalons.length >= 5) {
      return _cachedSalons.sublist(0, 5);
    }
    return _cachedSalons;
  }
}
