import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/source_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '518157188019-ilq64634pabf6008depromh27mg9hjjd.apps.googleusercontent.com',
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        try {
          await createUserProfile(
            userCredential.user!.uid, 
            userCredential.user!.email ?? '', 
            userCredential.user!.displayName ?? 'İsimsiz Kullanıcı'
          );
        } catch (e) {
          // Profile creation failed but auth succeeded, continue
        }
      }
      
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  /// Adds a news source for a specific user
  Future<void> addSource(String userId, String url, String category) async {
    await _db.collection('users').doc(userId).collection('sources').add({
      'url': url,
      'category': category,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches all sources for a specific user
  Future<List<SourceModel>> getSources(String userId) async {
    var snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('sources')
        .get();

    return snapshot.docs.map((doc) => SourceModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> createUserProfile(String userId, String email, String name) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        await _db.collection('users').doc(userId).set({
          'email': email,
          'displayName': name,
          'readNewsIds': [],
          'savedNewsIds': [],
          'sharedNewsIds': [],
          'categories': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('users').doc(userId).update({
          'email': email,
          'displayName': name,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates user categories
  Future<void> updateUserCategories(String userId, List<String> categories) async {
    await _db.collection('users').doc(userId).update({
      'categories': categories,
    });
  }

  /// Fetches user categories
  Future<List<String>> getUserCategories(String userId) async {
    var doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return List<String>.from(doc.data()!['categories'] ?? []);
    }
    return [];
  }
}
