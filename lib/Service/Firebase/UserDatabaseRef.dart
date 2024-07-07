import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dto/UserDetail.dart';

const String USER_COLLECTION_REF = "UserDetail";

class UserDatabaseRef{
  final _firestore = FirebaseFirestore.instance;


  Future<void> addUserDetail(UserDetail user) async{
    _firestore.collection(USER_COLLECTION_REF).add(user.toJson());
  }

  Future<UserDetail> getUserDetails(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final userData = snapshot.docs.map((e) => UserDetail.fromSnapshot(e)).single;
    return userData;
  }

  Future<void> updateUserDetail(int id,UserDetail userUpdated)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).update(userUpdated.toJson());
    }
  }
}