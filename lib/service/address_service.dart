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

  /// Stream of all saved addresses, ordered by createdAt descending.
  static Stream<List<SavedAddressModel>> streamAddresses() {
    final col = _addressCol;
    if (col == null) return const Stream.empty();

    return col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => SavedAddressModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Adds a new address and marks it as selected.
  /// Unmarks all previously selected addresses via a batch write.
  static Future<String> addAddress(SavedAddressModel model) async {
    final col = _addressCol;
    if (col == null) throw Exception('User not logged in');

    // Batch: unselect all existing, then add new doc selected
    final batch = _db.batch();

    final existing = await col.get();
    for (final doc in existing.docs) {
      if (doc.data()['isSelected'] == true) {
        batch.update(doc.reference, {'isSelected': false});
      }
    }

    final newRef = col.doc();
    batch.set(newRef, model.copyWith(id: newRef.id, isSelected: true).toMap());

    await batch.commit();
    return newRef.id;
  }

  /// Marks one address as selected and unmarks all others (batch).
  static Future<void> selectAddress(String docId) async {
    final col = _addressCol;
    if (col == null) return;

    final batch = _db.batch();
    final all = await col.get();

    for (final doc in all.docs) {
      batch.update(doc.reference, {'isSelected': doc.id == docId});
    }

    await batch.commit();
  }

  /// Toggles the isFavorite field on a specific address.
  static Future<void> toggleFavorite(String docId, bool currentValue) async {
    final col = _addressCol;
    if (col == null) return;
    await col.doc(docId).update({
      'isFavorite': !currentValue,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Deletes an address document.
  static Future<void> deleteAddress(String docId) async {
    final col = _addressCol;
    if (col == null) return;
    await col.doc(docId).delete();
  }
}
