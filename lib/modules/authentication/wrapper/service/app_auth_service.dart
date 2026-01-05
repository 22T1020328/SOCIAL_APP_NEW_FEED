import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/login_data.dart';
import 'auth_service.dart';

class AppAuthService implements AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<LoginData?> loginWithGmail() async {
    try {
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        
        
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        final isNewUser = !userDoc.exists;
        
        
        if (isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'id': user.uid,
            'email': user.email,
            'username': user.displayName?.replaceAll(' ', '_').toLowerCase() ?? 'user_${user.uid.substring(0, 8)}',
            'first_name': user.displayName?.split(' ').first ?? '',
            'last_name': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'avatar': user.photoURL != null ? {
              'url': user.photoURL,
              'org_url': user.photoURL,
              'org_width': 300,
              'org_height': 300,
            } : null,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }

        return LoginData(
          accessToken: googleAuth.accessToken,
          oauthId: user.uid,
          isNew: isNewUser,
        );
      }

      return null;
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw PlatformException(
        code: 'ERROR_BY_CONFIG',
        message: e.toString(),
      );
    }
  }
}

