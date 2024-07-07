import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dto/Topic.dart';
import '../../dto/UserDetail.dart';

const String USER_COLLECTION_REF = "Topics";

class TopicDatabaseRef{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addTopic(Topic topic) async{
    _firestore.collection(USER_COLLECTION_REF).add(topic.toJson());
  }

  Future<Topic> getTopics(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final topicData = snapshot.docs.map((e) => Topic.fromSnapshot(e)).single;
    return topicData;
  }

  Future<void> updateTopic(int id,String name,int progress)async {
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

  Future<void> deleteTopic(int id)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).delete();
    }
  }
}