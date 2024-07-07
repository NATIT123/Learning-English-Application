import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dto/Folder.dart';
import '../../dto/Folder.dart';
import '../../dto/UserDetail.dart';

const String USER_COLLECTION_REF = "Folders";

class FolderDatabaseRef{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addFolder(Folder folder) async{
    _firestore.collection(USER_COLLECTION_REF).add(folder.toJson());
  }

  Future<Folder> getFolder(int id)async{
    final snapshot = await _firestore.collection(USER_COLLECTION_REF).where("id",isEqualTo:id).get();
    final folderData = snapshot.docs.map((e) => Folder.fromSnapshot(e)).single;
    return folderData;
  }

  Future<void> updateFolder(int id,String name,bool isDelete)async {
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      Map<String, dynamic> updatedData = {
        'name': name,
        'isDelete': isDelete,
      };
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).update(updatedData);
    }
  }

  Future<void> deleteFolder(int id)async{
    QuerySnapshot querySnapshot = await _firestore.collection(USER_COLLECTION_REF).where('id', isEqualTo:id).get();
    if(querySnapshot.docs.isNotEmpty){
      String docId = querySnapshot.docs.first.id;
      await _firestore.collection(USER_COLLECTION_REF).doc(docId).delete();
    }
  }
}