

import 'package:cloud_firestore/cloud_firestore.dart';

class FolderTopic{
  int id;
  bool isDeleted;
  int topicId;
  int folderId;

  FolderTopic({required this.id,required this.isDeleted,required this.topicId,required this.folderId});

  factory FolderTopic.fromSqfLiteDatabase(Map<String,dynamic> map)=>FolderTopic(
    id:map['id']?.toInt()??0,
    isDeleted: map['isDelete']==1?true:false,
    topicId: map['topic_id']?.toInt()??0,
    folderId: map['folder_id']?.toInt()??0,

  );

  FolderTopic.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        isDeleted: json['isDeleted']! as bool,
        topicId: json['topicId']! as int,
        folderId: json['folderId']! as int,
      );

  FolderTopic copyWith({
    int? id,
    bool? isDeleted,
    int? topicId,
    int? userId,
  }){
    return FolderTopic(id: id ?? this.id, isDeleted: isDeleted ?? this.isDeleted, topicId: topicId ?? this.topicId, folderId: folderId ?? this.folderId);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'isDelete' : isDeleted,
      'topicId' : topicId,
      'folderId' : folderId,
    };
  }

  factory FolderTopic.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return FolderTopic.fromJson(data);
  }
}