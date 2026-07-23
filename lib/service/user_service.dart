import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../model/user_model.dart';

/// Handles all Firestore operations for the "user" collection.
class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Memory cache for the current user's profile to avoid unnecessary DB calls on page navigation.
  static UserModel? _cachedUser;

  /// Gets the currently cached user model (if any).
  static UserModel? get cachedUser => _cachedUser;

  /// Clears the memory cache (e.g. on logout).
  static void clearCache() {
    _cachedUser = null;
  }

  /// Reference to the "user" collection.
  static CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('user');

  /// Creates or updates the user document in Firestore after a successful login.
  ///
  /// Uses [SetOptions(merge: true)] so that subsequent logins do NOT overwrite
  /// fields that may have been updated later (e.g. phone, address, location).
  /// The [createdAt] field is only written on the very first login because of
  /// merge semantics — if the document already exists, existing fields are kept.
  static Future<void> createOrUpdateUser(User firebaseUser) async {
    try {
      debugPrint(
        '🔥 [UserService] Starting createOrUpdateUser for uid: ${firebaseUser.uid}',
      );

      final docRef = _usersCol.doc(firebaseUser.uid);

      final snapshot = await docRef.get();
      final isNewUser = !snapshot.exists;
      debugPrint(
        '🔥 [UserService] Document exists: ${snapshot.exists} | isNewUser: $isNewUser',
      );

      final now = Timestamp.now();
      final userData = UserModel(
        uid: firebaseUser.uid,
        name: isNewUser
            ? (firebaseUser.displayName ?? '')
            : (snapshot.data()?['name'] as String? ?? firebaseUser.displayName ?? ''),
        email: firebaseUser.email ?? '',
        phone: (snapshot.data()?['phone'] as num?)?.toInt() ?? 0,
        profileImages: isNewUser
            ? (firebaseUser.photoURL ?? '')
            : (snapshot.data()?['profileImages'] as String? ?? firebaseUser.photoURL ?? ''),
        pushToken: snapshot.data()?['pushToken'] as String? ?? '',
        lastLogin: now,
        createdAt: isNewUser
            ? now
            : (snapshot.data()?['createdAt'] as Timestamp? ?? now),
      );

      debugPrint('🔥 [UserService] Writing data: ${userData.toMap()}');

      await docRef.set(userData.toMap(), SetOptions(merge: true));
      _cachedUser = userData;

      debugPrint('✅ [UserService] User document written successfully!');
    } catch (e, stack) {
      debugPrint('❌ [UserService] ERROR writing user document: $e');
      debugPrint('❌ [UserService] StackTrace: $stack');
      rethrow; // bubble up so LoginController catch block shows it
    }
  }

  /// Fetches the current user's document from Firestore.
  /// Returns cached memory copy if available, avoiding extra DB calls when changing pages.
  static Future<UserModel?> getCurrentUser({bool forceRefresh = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    if (!forceRefresh && _cachedUser != null && _cachedUser!.uid == uid) {
      debugPrint('⚡ [UserService] Returning cached user profile without DB call.');
      return _cachedUser;
    }

    debugPrint('🔥 [UserService] Fetching user profile from Firestore DB...');
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    _cachedUser = UserModel.fromMap(doc.data()!);
    return _cachedUser;
  }

  /// Updates specific fields on the user's Firestore document and updates memory cache.
  static Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    debugPrint('🔥 [UserService] Updating user fields in Firestore: $fields');
    await _usersCol.doc(uid).set(fields, SetOptions(merge: true));

    if (_cachedUser != null && _cachedUser!.uid == uid) {
      _cachedUser = _cachedUser!.copyWith(
        name: fields['name'] as String?,
        email: fields['email'] as String?,
        phone: fields['phone'] is int
            ? fields['phone'] as int
            : (fields['phone'] as num?)?.toInt(),
        profileImages: fields['profileImages'] as String?,
        pushToken: fields['pushToken'] as String?,
      );
    }
  }
}
