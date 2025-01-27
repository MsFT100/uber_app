import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/user.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  static const LOGGED_IN = "loggedIn";
  static const ID = "id";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  Status _status = Status.Uninitialized;
  final UserServices _userServices = UserServices();
  UserModel? _userModel;
  bool _isActiveRememberMe = false;

  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Getters
  UserModel? get userModel => _userModel;
  Status get status => _status;
  User? get user => _user;
  bool get isActiveRememberMe => _isActiveRememberMe;

  // Text controllers for input
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();

  UserProvider.initialize() {
    _initialize();
  }

  get isRememberMe => false;

  /// Sign-in method
  Future<String> signIn() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      _user = result.user;
      if (_user != null) {
        await _saveUserToPreferences(_user!);
        _userModel = await _userServices.getUserById(_user!.uid);
        _status = Status.Authenticated;
        notifyListeners();
        return "Success";
      } else {
        return "Failed to sign in user.";
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found':
          return "No user found for that email.";
        case 'wrong-password':
          return "Wrong password provided for the user.";
        case 'invalid-email':
          return "The email address is not valid.";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred: $e";
    }
  }

  /// Sign-up method
  Future<String> signUp() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      _user = result.user;
      if (_user != null) {
        await _saveUserToPreferences(_user!);
        await _userServices.createUser(
          id: _user!.uid,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          position: {},
        );
        _userModel = await _userServices.getUserById(_user!.uid);
        _status = Status.Authenticated;
        notifyListeners();
        return "Success";
      } else {
        return "Failed to create user.";
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use':
          return "The email address is already in use by another account.";
        case 'invalid-email':
          return "The email address is not valid.";
        case 'weak-password':
          return "The password provided is too weak.";
        case 'The supplied auth credential is incorrect, malformed or has expired.':
          return "Incorrect credentials";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return "An unknown error occurred: $e";
    }
  }

  /// Sign-out method
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _clearUserFromPreferences();
    _status = Status.Unauthenticated;
    _user = null;
    _userModel = null;
    notifyListeners();
  }

  /// Reload user model after updates
  Future<void> reloadUserModel() async {
    if (_user != null) {
      _userModel = await _userServices.getUserById(_user!.uid);
      notifyListeners();
    }
  }

  /// Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
    await reloadUserModel();
  }

  /// Save device token (e.g., for FCM)
  Future<void> saveDeviceToken() async {
    String? deviceToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (deviceToken != null && _user != null) {
      _userServices.addDeviceToken(userId: _user!.uid, token: deviceToken);
    }
  }

  /// Initialize user status and preferences
  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(LOGGED_IN) ?? false;

    if (isLoggedIn) {
      FirebaseAuth.instance.authStateChanges().listen((currentUser) async {
        if (currentUser != null) {
          _user = currentUser;
          _userModel = await _userServices.getUserById(_user!.uid);
          _status = Status.Authenticated;
        } else {
          _status = Status.Unauthenticated;
        }
        notifyListeners();
      });
    } else {
      _status = Status.Unauthenticated;
      notifyListeners();
    }
  }

  /// Save user data to preferences
  Future<void> _saveUserToPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LOGGED_IN, true);
    await prefs.setString(ID, user.uid);
    await _secureStorage.write(key: 'user_email', value: user.email);
  }

  /// Clear user data from preferences
  Future<void> _clearUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LOGGED_IN);
    await prefs.remove(ID);
    await _secureStorage.deleteAll();
  }

  // Inside UserProvider class
  void clearController() {
    email.clear();
    password.clear();
    name.clear();
    phone.clear();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    //update();
  }

  void setRememberMe() {
    _isActiveRememberMe = true;
  }
}
