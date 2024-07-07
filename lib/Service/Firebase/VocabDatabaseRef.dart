import 'package:cloud_firestore/cloud_firestore.dart';

import '../../dto/Vocab.dart';

const String USER_COLLECTION_REF = "Vocabs";

class VocabDatabaseRef{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addVocab(Vocab vocab) async{
    _firestore.collection(USER_COLLECTION_REF).add(vocab.toJson());
  }

  Future<Vocab> getTopics(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final topicData = snapshot.docs.map((e) => Vocab.fromSnapshot(e)).single;
    return topicData;
  }

  Future<void> updateVocab(int id,String en,String vi ,bool isMark)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      Map<String, dynamic> updatedData = {
        'en': en,
        'vi': vi,
        'isMark': isMark
      };
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).update(updatedData);
    }
  }

  Future<void> deleteVocab(int id)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).delete();
    }
  }

  Future<void> deleteVocabByTopicId(int topicId)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('topicId', isEqualTo:topicId).get();
    if(querySnapshot.docs.isNotEmpty){
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Delete the document
        await _firestore.collection(USER_COLLECTION_REF).doc(doc.id).delete();
      }
    }
  }



}