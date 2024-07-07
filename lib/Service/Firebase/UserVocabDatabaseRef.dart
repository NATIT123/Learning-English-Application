
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dto/UserDetail.dart';
import '../../dto/UserVocab.dart';

const String USER_COLLECTION_REF = "UserVocab";

class UserVocabDatabaseRef{
  final _firestore = FirebaseFirestore.instance;


  Future<void> addUserVocab(UserVocab userVocab) async{
    _firestore.collection(USER_COLLECTION_REF).add(userVocab.toJson());
  }

  Future<UserVocab> getUserVocab(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final userVocab = snapshot.docs.map((e) => UserVocab.fromSnapshot(e)).single;
    return userVocab;
  }

  Future<void> updateUserVocab(int id,UserVocab userVocab)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).update(userVocab.toJson());
    }
  }

  Future<void> deleteUserVocab(int userId,int vocabId)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('userId', isEqualTo:userId).where('vocabId',isEqualTo: vocabId).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).delete();
    }
  }


}