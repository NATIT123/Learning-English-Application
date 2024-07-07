import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../dto/UserDetail.dart';
import '../Sqlite/UserDatabase.dart';
import 'UserDatabaseRef.dart';
import 'SharedPref.dart';

// import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserDatabaseRef databaseRef = UserDatabaseRef();
  SharedPrefService sharedPref = SharedPrefService();
  final userDatabase = UserDatabase();
  bool cc = false;
  var _user;

  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<bool> checkUserExist(UserCredential result) async {
    final User? user = auth.currentUser;
    final email = user?.email;

    await FirebaseFirestore.instance.collection("UserDetail").get().then((QuerySnapshot snapshot){
      for (var doc in snapshot.docs) {
        if(doc["email"]==email){
          cc = true;
        }
      }
    });
    return cc;
  }


  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
    await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;
    if(await checkUserExist(result) == false){
      //SQLite
      var id = await userDatabase.create(fullName: userDetails!.displayName.toString(), userName: userDetails.email.toString().substring(0,userDetails.email.toString().indexOf('@')),
          email: userDetails.email.toString(), password: "", imgPath: userDetails.photoURL.toString());
      id ??= await userDatabase.create(fullName: userDetails.displayName.toString(), userName: userDetails.email.toString().substring(0,userDetails.email.toString().indexOf('@')),
          email: userDetails.email.toString(), password: "", imgPath: userDetails.photoURL.toString());


      //Firebase
      UserDetail user = UserDetail(fullName: userDetails.displayName.toString(), userName: userDetails.email.toString().substring(0,userDetails.email.toString().indexOf('@')), email: userDetails.email.toString(),
          imgPath: userDetails.photoURL.toString(), id: id ?? 0);
      await databaseRef.addUserDetail(user);
    }
    _user = await userDatabase.fetchByEmail(userDetails!.email.toString());
    _user ??= await userDatabase.fetchByEmail(userDetails.email.toString());

    sharedPref.write(key: "user", value: jsonEncode(_user?.toJson()));
    sharedPref.write(key: "pw", value: "");
    Navigator.pushNamed(context, '/home');
  }

// Future<User> signInWithApple({List<Scope> scopes = const []}) async {
//   final result = await TheAppleSignIn.performRequests(
//       [AppleIdRequest(requestedScopes: scopes)]);
//   switch (result.status) {
//     case AuthorizationStatus.authorized:
//       final AppleIdCredential = result.credential!;
//       final oAuthCredential = OAuthProvider('apple.com');
//       final credential = oAuthCredential.credential(
//           idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
//       final UserCredential = await auth.signInWithCredential(credential);
//       final firebaseUser = UserCredential.user!;
//       if (scopes.contains(Scope.fullName)) {
//         final fullName = AppleIdCredential.fullName;
//         if (fullName != null &&
//             fullName.givenName != null &&
//             fullName.familyName != null) {
//           final displayName = '${fullName.givenName}${fullName.familyName}';
//           await firebaseUser.updateDisplayName(displayName);
//         }
//       }
//       return firebaseUser;
//     case AuthorizationStatus.error:
//       throw PlatformException(
//           code: 'ERROR_AUTHORIZATION_DENIED',
//           message: result.error.toString());
//
//     case AuthorizationStatus.cancelled:
//       throw PlatformException(
//           code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
//     default:
//       throw UnimplementedError();
//   }
// }
}
