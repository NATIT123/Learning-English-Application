import 'package:cloud_firestore/cloud_firestore.dart';

class Topic{
  int id;
  String nameTopic;
  bool isPublic;
  String createdAt;
  int userId;
  int progress;


  Topic({required this.id,required this.nameTopic,required this.isPublic,required this.createdAt,required this.userId,required this.progress});

  factory Topic.fromSqfLiteDatabase(Map<String,dynamic> map)=>Topic(
    id:map['id']?.toInt()??0,
    nameTopic: map['name']??'',
    isPublic: map['isPublic']==1?true:false,
    createdAt:map['createdAt']??'',
    userId:map['userId'].toInt()??0,
    progress: map['progress']?.toInt()??0,
  );

  Topic.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        nameTopic: json['nameTopic']! as String,
        isPublic: json['isPublic']! as bool,
        userId: json['userId']! as int,
        createdAt: json['createdAt']! as String,
        progress: json['progress']! as int,
      );

  Topic copyWith({
    int? id,
    String? nameTopic,
    bool? isPublic,
    String? createdAt,
    int? userId,
    int? progress,
  }){
    return Topic(id: id ?? this.id,nameTopic: nameTopic ?? this.nameTopic, isPublic: isPublic ?? this.isPublic, progress: progress ?? this.progress
        , createdAt: createdAt ?? this.createdAt, userId: userId ?? this.userId);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'nameTopic' : nameTopic,
      'isPublic' : isPublic,
      'progress' : progress,
      'createdAt' : createdAt,
      'userId' : userId,
    };
  }

  factory Topic.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return Topic.fromJson(data);
  }

}