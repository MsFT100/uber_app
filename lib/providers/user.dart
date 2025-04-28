import 'dart:async';
import 'dart:io';

import 'package:BucoRide/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
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
  List<TripModel> _trips = [];
  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Getters
  UserModel? get userModel => _userModel;
  Status get status => _status;
  User? get user => _user;
  bool get isActiveRememberMe => _isActiveRememberMe;

  List<TripModel> get trips => _trips;

  // Text controllers for input
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _verificationId;
  String _formattedPhone = "";
  String get formattedPhone => _formattedPhone;
  String? get verificationId => _verificationId;

  set verificationId(String? id) {
    _verificationId = id;
    notifyListeners(); // Notify listeners when it's updated
  }

  UserProvider() {
    _initialize();
  }

  void setFormattedPhone(String phoneNumber) {
    _formattedPhone = phoneNumber;
    notifyListeners();
  }

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
        if (_isActiveRememberMe) {
          await _saveUserToPreferences(_user!);
        }

        _userModel = await _userServices.getUserById(_user!.uid);
        print(_userModel?.name);

        if (_userModel?.name == null) {
          _status = Status.Unauthenticated;
          notifyListeners();
          return "🚗 🚗Something went wrong. We don't have your account in our database.";
        } else {
          _status = Status.Authenticated;
          await reloadUser();
          notifyListeners();
          return "Success";
        }
      } else {
        _status = Status.Unauthenticated;
        notifyListeners();
        return "Failed to sign in user.";
      }
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      switch (e.code) {
        case 'The supplied auth credential is incorrect, malformed or has expired.':
          return "Wrong email or password provided.";
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

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        // Try fetching user data
        _userModel = await _userServices.getUserById(_user!.uid);

        // If user does not exist in Firestore, create a new entry
        if (_userModel == null) {
          await _userServices.createUser(
            id: _user!.uid,
            name: _user!.displayName ?? '',
            email: _user!.email ?? '',
            phone: _user!.phoneNumber ?? '',
            position: {},
            photo: "${user!.photoURL}",
          );

          // Fetch the newly created user data
          _userModel = await _userServices.getUserById(_user!.uid);
        }

        _status = Status.Authenticated;
        await reloadUser();
        notifyListeners();
      }

      return _user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<String> uploadProfilePix(File imageFile, String uid) async {
    try {
      // ✅ Create storage reference for user's profile picture
      Reference storageRef =
          FirebaseStorage.instance.ref().child("profile_pictures/$uid.jpg");

      // ✅ Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // ✅ Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw "Error uploading profile picture: $e";
    }
  }

  Future<bool> PhoneSignIn(String phoneNumber, BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _status = Status.Authenticated;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _status = Status.Unauthenticated;
          notifyListeners();

          String errorMessage = "Verification failed. Try again.";

          if (e.code == 'invalid-phone-number') {
            errorMessage =
                "Invalid phone number format. Please check and try again.";
          } else if (e.code == 'quota-exceeded') {
            errorMessage = "Too many OTP requests. Try again later.";
          } else {
            errorMessage = e.message ?? errorMessage;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          notifyListeners();

          // ✅ Notify user OTP is sent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent successfully!")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );

      return true; // ✅ OTP Sent Successfully
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      return false; // ❌ Failed to Send OTP
    }
  }

  /// Sign-up method
  Future<String> signUp({required File profileImage}) async {
    try {
      // Validate Required Fields
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        return "Email and Password cannot be empty.";
      }
      if (name.text.trim().isEmpty) {
        return "Full Name is required.";
      }
      if (phone.text.trim().isEmpty) {
        return "Phone number is required.";
      }

      _status = Status.Authenticating;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      _user = result.user;
      if (_user != null) {
        // ✅ Step 3: Upload Profile Picture After Signup
        String imageUrl = await uploadProfilePix(profileImage, _user!.uid);

        // ✅ Step 4: Update Firebase User Profile
        await _user!.updateDisplayName(name.text.trim());
        await _user!.updatePhotoURL(imageUrl);

        await _saveUserToPreferences(_user!);
        await _userServices.createUser(
          id: _user!.uid,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          photo: imageUrl,
          position: {},
        );

        // Step 3: Link Phone Number to FirebaseAuth
        await _auth.verifyPhoneNumber(
          phoneNumber: phone.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _user!.linkWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            print("Phone verification failed: ${e.message}");
            //return "Check Your Phone Number";
          },
          codeSent: (String verificationId, int? resendToken) {
            print("OTP Sent");
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );

        _userModel = await _userServices.getUserById(_user!.uid);
        _status = Status.Authenticated;
        await reloadUser();
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

  Future<String> ResetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.text.trim());
      return "Success";
    } on FirebaseException {
      return ("Something Went Wrong. Check your Email");
    }
  }

  /// Sign-out method
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await _clearUserFromPreferences();
    _status = Status.Unauthenticated;
    _user = null;
    _userModel = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false); // Reset Remember Me
    _isActiveRememberMe = false;

    notifyListeners();
  }

  /// Reload user model after updates
  Future<void> reloadUserModel() async {
    if (_user != null) {
      _userModel = await _userServices.getUserById(_user!.uid);
      notifyListeners();
    }
  }

  Future<void> updateUserData(UserModel userM) async {
    _userServices.updateUserData(userM);
    await reloadUserModel();
    await reloadUser();
  }

  Future<void> updateProfilePic(XFile image) async {
    try {
      String? photoURL;

      // Reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_pictures/${user!.uid}.jpg');

      // Convert XFile to bytes and upload
      final imageBytes = await image.readAsBytes();
      await imageRef.putData(imageBytes);

      // Get the download URL of the uploaded image
      photoURL = await imageRef.getDownloadURL();

      // Update the Firebase Auth profile with the new photo URL
      await user!.updatePhotoURL(photoURL);
      await user!.reload(); // Reload the user to reflect the new photoURL

      // Update local user data
      _user = FirebaseAuth.instance.currentUser;

      // Reload Firestore user model if needed
      await reloadUserModel();
      await reloadUser();

      notifyListeners();
    } catch (e) {
      print("Error updating profile picture: $e");
    }
  }

  // Method to refresh user data from Firebase
  Future<void> refreshUser() async {
    if (_user != null) {
      await _user!.reload(); // Reloads the user from Firebase
      _user = FirebaseAuth.instance.currentUser; // Update local user data
      notifyListeners(); // Notifies UI to rebuild with new data
    }
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
    _status = Status.Authenticating;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isActiveRememberMe = prefs.getBool('remember_me') ?? false;

    bool isLoggedIn = prefs.getBool(LOGGED_IN) ?? false;
    if (isLoggedIn && _isActiveRememberMe) {
      String? userId = prefs.getString(ID);
      if (userId != null) {
        _userModel = await _userServices.getUserById(userId);
        _user = _auth.currentUser;
        _status = Status.Authenticated;
      } else {
        _status = Status.Unauthenticated;
      }
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
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

  void toggleRememberMe() async {
    _isActiveRememberMe = !_isActiveRememberMe;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _isActiveRememberMe);
    notifyListeners();
  }

  // Fetch trips for the currently logged-in driver
  Future<void> fetchDriverTrips() async {
    try {
      if (_userModel == null) return; // Ensure user is logged in
      String userId = _userModel!.id;

      QuerySnapshot snapshot = await _firestore
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _trips =
          snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching trips: $e");
    }
  }

  Future<void> reloadUser() async {
  if (_user != null) {
    _userModel = await _userServices.getUserById(_user!.uid);
    notifyListeners();
  }
}
}
