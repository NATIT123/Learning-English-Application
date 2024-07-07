import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/dto/History.dart';

import '../../dto/Vocab.dart';

const String USER_COLLECTION_REF = "History";

class HistoryDatabaseRef{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addHistory(History history) async{
    _firestore.collection(USER_COLLECTION_REF).add(history.toJson());
  }

  Future<History> getHistory(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final historyData = snapshot.docs.map((e) => History.fromSnapshot(e)).single;
    return historyData;
  }





}