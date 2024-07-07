import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/dto/FolderTopic.dart';
import '../../dto/Topic.dart';
import '../../dto/UserDetail.dart';

const String USER_COLLECTION_REF = "FolderTopic";

class FolderTopicDatabaseRef{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addFolderTopic(FolderTopic folderTopic) async{
    _firestore.collection(USER_COLLECTION_REF).add(folderTopic.toJson());
  }

  Future<FolderTopic> getFolderTopic(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final topicData = snapshot.docs.map((e) => FolderTopic.fromSnapshot(e)).single;
    return topicData;
  }

  Future<void> updateFolderTopic(int id,String name,int progress)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      Map<String, dynamic> updatedData = {
        'nameTopic': name,
        'progress': progress,
      };
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).update(updatedData);
    }
  }

  Future<void> deleteFolderTopic(int folderId)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('folderId', isEqualTo:folderId).get();
    if(querySnapshot.docs.isNotEmpty){
      if(querySnapshot.docs.isNotEmpty){
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          // Delete the document
          await _firestore.collection(USER_COLLECTION_REF).doc(doc.id).delete();
        }
      }
    }
  }
  Future<void> deleteTopicAndFolder(int folderId,int topicId)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('folderId', isEqualTo:folderId).where('topicId', isEqualTo:topicId).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).delete();
    }
  }
}