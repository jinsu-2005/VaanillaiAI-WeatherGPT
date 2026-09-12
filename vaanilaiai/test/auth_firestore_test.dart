import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vaanilaiai/providers/auth_provider.dart';
import 'package:vaanilaiai/models/location_model.dart';
import 'package:vaanilaiai/services/auth_service.dart';

void main() {
  group('Auth & Firestore Models and Error Resolution Tests', () {
    test('UserModel roleDisplayName returns accurate designation and icon', () {
      final citizen = UserModel(
        uid: 'user_1',
        displayName: 'Aarav',
        email: 'aarav@example.com',
        role: UserRole.citizen,
      );
      expect(citizen.roleDisplayName.contains('Citizen'), true);
      expect(citizen.isGuest, false);

      final farmer = UserModel(
        uid: 'user_2',
        displayName: 'Kavitha',
        email: 'kavitha@example.com',
        role: UserRole.farmer,
      );
      expect(farmer.roleDisplayName.contains('Farmer'), true);
      expect(farmer.roleDisplayName.contains('🌾'), true);
    });

    test('UserModel roleFromString parses role variants accurately', () {
      expect(UserModel.roleFromString('farmer'), UserRole.farmer);
      expect(UserModel.roleFromString('fisherman'), UserRole.fisherman);
      expect(UserModel.roleFromString('disasterManager'), UserRole.disasterManager);
      expect(UserModel.roleFromString('citizen'), UserRole.citizen);
      expect(UserModel.roleFromString(null), UserRole.citizen);
      expect(UserModel.roleFromString('unknown_role'), UserRole.citizen);
    });

    test('SavedLocationModel serialization and deserialization for Firestore', () {
      final loc = SavedLocationModel(
        id: 101,
        name: 'Thanjavur',
        district: 'Thanjavur',
        state: 'Tamil Nadu',
        country: 'India',
        latitude: 10.7870,
        longitude: 79.1378,
        isVillage: false,
        isFavorite: true,
      );

      final json = loc.toJson();
      expect(json['name'], 'Thanjavur');
      expect(json['is_favorite'], true);

      final reconstructed = SavedLocationModel.fromJson(json);
      expect(reconstructed.id, 101);
      expect(reconstructed.name, 'Thanjavur');
      expect(reconstructed.latitude, 10.7870);
    });

    test('AuthService friendly error mapping resolves FirebaseAuth exceptions', () {
      final userNotFound = FirebaseAuthException(code: 'user-not-found');
      expect(AuthService.getFriendlyErrorMessage(userNotFound).contains('No user found'), true);

      final wrongPassword = FirebaseAuthException(code: 'wrong-password');
      expect(AuthService.getFriendlyErrorMessage(wrongPassword).contains('Incorrect email or password'), true);

      final emailInUse = FirebaseAuthException(code: 'email-already-in-use');
      expect(AuthService.getFriendlyErrorMessage(emailInUse).contains('already exists'), true);

      final weakPassword = FirebaseAuthException(code: 'weak-password');
      expect(AuthService.getFriendlyErrorMessage(weakPassword).contains('at least 6 characters'), true);

      final customError = Exception('Generic network timeout');
      expect(AuthService.getFriendlyErrorMessage(customError), 'Exception: Generic network timeout');
    });
  });
}
