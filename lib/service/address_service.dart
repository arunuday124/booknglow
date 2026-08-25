import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/saved_address_model.dart';

/// Handles all Firestore operations for `user/{uid}/savedAddress` subcollection.
class AddressService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the savedAddress subcollection ref for the current user.
  static CollectionReference<Map<String, dynamic>>? get _addressCol {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('user').doc(uid).collection('savedAddress');
  }

  static List<SavedAddressModel>? _cachedAddresses;
  static DateTime? _cachedTime;

  /// Clears in-memory address cache
  static void clearCache() {
    _cachedAddresses = null;
    _cachedTime = null;
  }

  /// Fetches all saved addresses once, ordered by createdAt descending (with 5-minute memory cache).
  static Future<List<SavedAddressModel>> fetchAddresses({
    bool forceRefresh = false,
  }) async {
    final col = _addressCol;
    if (col == null) return [];

    if (!forceRefresh &&
        _cachedAddresses != null &&
        _cachedTime != null &&
        DateTime.now().difference(_cachedTime!).inMinutes < 5) {
      return _cachedAddresses!;
    }

    final snap = await col.orderBy('createdAt', descending: true).get();
    final list = snap.docs
        .map((doc) => SavedAddressModel.fromMap(doc.id, doc.data()))
        .toList();

    _cachedAddresses = list;
    _cachedTime = DateTime.now();
    return list;
  }

  /// Adds a new address and marks it as selected.
  /// Unmarks all previously selected addresses via a batch write.
  static Future<String> addAddress(SavedAddressModel model) async {
    final col = _addressCol;
    if (col == null) throw Exception('User not logged in');

    clearCache();

    // Batch: unselect currently selected address, then add new doc selected
    final batch = _db.batch();

    final currentlySelected =
        await col.where('isSelected', isEqualTo: true).get();
    for (final doc in currentlySelected.docs) {
      batch.update(doc.reference, {'isSelected': false});
    }

    final newRef = col.doc();
    batch.set(newRef, model.copyWith(id: newRef.id, isSelected: true).toMap());

    await batch.commit();
    return newRef.id;
  }

  /// Updates an existing address document in Firestore.
  static Future<void> updateAddress(String docId, SavedAddressModel model) async {
    final col = _addressCol;
    if (col == null) throw Exception('User not logged in');

    clearCache();
    await col.doc(docId).update(model.toMap());
  }

  /// Marks one address as selected and unmarks all others (batch).
  /// Queries only currently selected document to reduce Firebase reads.
  static Future<void> selectAddress(String docId) async {
    final col = _addressCol;
    if (col == null) return;

    clearCache();
    final batch = _db.batch();

    // Query only currently selected address doc (1 read instead of fetching all docs)
    final currentlySelected =
        await col.where('isSelected', isEqualTo: true).get();

    for (final doc in currentlySelected.docs) {
      if (doc.id != docId) {
        batch.update(doc.reference, {'isSelected': false});
      }
    }

    // Mark target address selected
    batch.update(col.doc(docId), {'isSelected': true});

    await batch.commit();
  }

  /// Toggles the isFavorite field on a specific address.
  static Future<void> toggleFavorite(String docId, bool currentValue) async {
    final col = _addressCol;
    if (col == null) return;
    clearCache();
    await col.doc(docId).update({
      'isFavorite': !currentValue,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Deletes an address document.
  static Future<void> deleteAddress(String docId) async {
    final col = _addressCol;
    if (col == null) return;
    clearCache();
    await col.doc(docId).delete();
  }
}
