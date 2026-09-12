import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Collection References ---
  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _alertsRef => _firestore.collection('public_alerts');

  CollectionReference<Map<String, dynamic>> _savedLocationsRef(String uid) =>
      _usersRef.doc(uid).collection('saved_locations');

  CollectionReference<Map<String, dynamic>> _chatHistoryRef(String uid) =>
      _usersRef.doc(uid).collection('chat_history');

  // ==========================================
  // 1. User Profile Management
  // ==========================================

  /// Save or sync user profile to Firestore `users/{uid}`
  Future<void> syncUserProfile(UserModel user) async {
    if (user.isGuest || user.uid.startsWith('guest_')) return;

    try {
      final docRef = _usersRef.doc(user.uid);
      final docSnapshot = await docRef.get();

      final data = <String, dynamic>{
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'role': user.role.name,
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      if (!docSnapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
      debugPrint('Firestore: User profile synced for ${user.uid}');
    } catch (e) {
      debugPrint('Firestore: Error syncing user profile: $e');
    }
  }

  /// Fetch user profile from Firestore `users/{uid}`
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore: Error fetching user profile: $e');
    }
    return null;
  }

  /// Stream user profile for real-time changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots();
  }

  /// Update only the user role in Firestore
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersRef.doc(uid).set({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore: Error updating user role: $e');
    }
  }

  // ==========================================
  // 2. Saved Locations Management
  // ==========================================

  /// Save or update a favorite/saved location for a user
  Future<void> saveLocation(String uid, SavedLocationModel location) async {
    if (uid.startsWith('guest_')) return;

    try {
      final docId = location.id.toString();
      final data = location.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _savedLocationsRef(uid).doc(docId).set(data, SetOptions(merge: true));
      debugPrint('Firestore: Location saved: ${location.name}');
    } catch (e) {
      debugPrint('Firestore: Error saving location: $e');
    }
  }

  /// Delete a saved location
  Future<void> deleteLocation(String uid, int locationId) async {
    if (uid.startsWith('guest_')) return;

    try {
      await _savedLocationsRef(uid).doc(locationId.toString()).delete();
      debugPrint('Firestore: Location deleted: $locationId');
    } catch (e) {
      debugPrint('Firestore: Error deleting location: $e');
    }
  }

  /// Fetch all saved locations for a user once
  Future<List<SavedLocationModel>> getSavedLocations(String uid) async {
    if (uid.startsWith('guest_')) return [];

    try {
      final snapshot = await _savedLocationsRef(uid).get();
      return snapshot.docs.map((doc) => SavedLocationModel.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Firestore: Error fetching saved locations: $e');
      return [];
    }
  }

  /// Real-time stream of saved locations
  Stream<List<SavedLocationModel>> streamSavedLocations(String uid) {
    if (uid.startsWith('guest_')) return Stream.value([]);

    return _savedLocationsRef(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SavedLocationModel.fromJson(doc.data())).toList();
    });
  }

  // ==========================================
  // 3. Chat History Management
  // ==========================================

  /// Store a chat message in `users/{uid}/chat_history`
  Future<void> saveChatMessage(String uid, ChatMessageModel message) async {
    if (uid.startsWith('guest_')) return;

    try {
      await _chatHistoryRef(uid).add({
        'role': message.role,
        'content': message.content,
        'language': message.language,
        'intent': message.intent,
        'detectedLocation': message.detectedLocation,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore: Error saving chat message: $e');
    }
  }

  /// Stream chat messages in chronological order
  Stream<List<ChatMessageModel>> streamChatHistory(String uid) {
    if (uid.startsWith('guest_')) return Stream.value([]);

    return _chatHistoryRef(uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            DateTime? ts;
            if (data['timestamp'] is Timestamp) {
              ts = (data['timestamp'] as Timestamp).toDate();
            }
            return ChatMessageModel(
              role: data['role'] ?? 'assistant',
              content: data['content'] ?? '',
              language: data['language'] ?? 'en',
              intent: data['intent'],
              detectedLocation: data['detectedLocation'],
              timestamp: ts,
            );
          }).toList();
        });
  }

  // ==========================================
  // 4. Public Meteorological Alerts
  // ==========================================

  /// Stream public alerts from `public_alerts`
  Stream<QuerySnapshot<Map<String, dynamic>>> streamPublicAlerts() {
    return _alertsRef.snapshots();
  }
}
