

import 'package:cloud_firestore/cloud_firestore.dart';

class UserVocab{
  int id;
  String statusStudy;
  int numStudy;
  int valueTrue;
  int vocabId;
  int userId;

  UserVocab({required this.id,required this.statusStudy,required this.vocabId,required this.userId,required this.numStudy,required this.valueTrue});

  factory UserVocab.fromSqfLiteDatabase(Map<String,dynamic> map)=>UserVocab(
    id:map['id']?.toInt()??0,
    userId:map['userId']??'',
    statusStudy: map['statusStudy']??'',
    vocabId: map['vocabId']??0,
    numStudy: map['numStudy'].toInt()??0,
    valueTrue: map['valueTrue'].toInt()??0,
  );

  UserVocab.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        statusStudy: json['statusStudy']! as String,
        numStudy: json['numStudy']! as int,
        valueTrue: json['valueTrue']! as int,
        userId: json['userId']! as int,
        vocabId: json['vocabId']! as int,
      );

  UserVocab copyWith({
    int? id,
    String? statusStudy,
    int? numStudy,
    int? valueTrue,
    int? userId,
    int? vocabId,
  }){
    return UserVocab(id: id ?? this.id,statusStudy: statusStudy ?? this.statusStudy, numStudy: numStudy ?? this.numStudy, valueTrue: valueTrue ?? this.valueTrue
        , vocabId: vocabId ?? this.vocabId, userId: userId ?? this.userId);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'statusStudy' : statusStudy,
      'numStudy' : numStudy,
      'valueTrue' : valueTrue,
      'vocabId' : vocabId,
      'userId' : userId,
    };
  }

  factory UserVocab.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return UserVocab.fromJson(data);
  }

}