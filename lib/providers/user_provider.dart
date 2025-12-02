import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/rider.dart';
import '../services/api_service.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final ApiService _apiService = ApiService();

  User? _user;
  Rider? _rider;
  Status _status = Status.Uninitialized;
  String? _accessToken;
  bool _isSigningUp = false;
  StreamSubscription<User?>? _authStateSubscription;

  // Text editing controllers
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();

  User? get user => _user;
  Rider? get rider => _rider;
  Status get status => _status;
  String? get accessToken => _accessToken;

  UserProvider.initialize()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn() {
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_isSigningUp) return; // Don't do anything if a sign-up is in progress.

    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      await login();
    }
    notifyListeners();
  }

  Future<String> signIn() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message ?? "An unknown error occurred.";
    }
  }

  Future<String> signUp({required File profileImage}) async {
    _isSigningUp = true;
    try {
      _status = Status.Authenticating;
      notifyListeners();

      // 1. Create the user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());

      // 2. Register the user on your backend
      await _apiService.registerRider(
        uid: credential.user!.uid,
        name: name.text,
        email: email.text,
        phone: phone.text,
      );

      // 3. Now, manually log in to your backend
      _user = credential.user;
      await login();

      // 4. Check if the login was successful and update the status
      if (_rider != null) {
        _status = Status.Authenticated;
        notifyListeners();
        return "Success";
      } else {
        throw Exception('Backend login failed after registration.');
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      _status = Status.Unauthenticated;
      // Clean up the created Firebase user if backend registration or login fails
      if (await _auth.currentUser != null) {
        await _auth.currentUser?.delete();
      }
      notifyListeners();
      debugPrint('Sign up failed: $e');
      return 'Registration failed. Please try again.';
    } finally {
      _isSigningUp = false; // Reset the flag
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = Status.Unauthenticated;
        notifyListeners();
        return "Google sign in was cancelled.";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return "Success";
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred.";
    }
  }

  Future<void> login({int retries = 0}) async {
    try {
      final idToken = await _user?.getIdToken();
      if (idToken == null) throw Exception('Could not get ID token.');

      final response = await _apiService.loginRider(idToken);
      _rider = response.rider;
      _accessToken = response.accessToken;
      _status = Status.Authenticated;
    } catch (e) {
      // Retry logic for the specific race condition where the backend hasn't created the user yet.
      if (e.toString().contains('Rider not found') && retries < 3) {
        await Future.delayed(const Duration(seconds: 2));
        await login(retries: retries + 1);
      } else {
        debugPrint('Login Error: $e');
        _status = Status.Unauthenticated;
        // DO NOT sign out here. This was the cause of the login loop.
      }
    }
    notifyListeners();
  }

  void clearController() {
    email.clear();
    password.clear();
    name.clear();
    phone.clear();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _status = Status.Unauthenticated;
    _rider = null;
    _accessToken = null;
    notifyListeners();
  }

  Future<void> updateUserData(Rider rider) async {
    try {
      _rider = rider;
      notifyListeners();
    } catch (e) {
      print('Update User Data Error: $e');
      rethrow;
    }
  }
}
