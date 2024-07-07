import 'package:cloud_firestore/cloud_firestore.dart';

class History{
  int? id;
  String typeTest;
  int numCorrect;
  int numIncorrect;
  String createdAt;
  int timeComplete;
  int topicId;
  int userId;


  History({required this.id,required this.typeTest,required this.numCorrect,required this.numIncorrect,required this.createdAt,required this.timeComplete,required this.userId,required this.topicId});

  factory History.fromSqfLiteDatabase(Map<String,dynamic> map)=>History(
    id:map['id']?.toInt()??0,
    createdAt:map['createdAt']??'',
    userId:map['userId']??'',
    typeTest: map['typeTest']??'',
    numCorrect: map['numCorrect']??0,
    numIncorrect: map['numIncorrect']??0,
    timeComplete: map['timeComplete']??0,
    topicId: map['topicId']??0,

  );

  History.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        createdAt: json['createdAt']! as String,
        typeTest: json['typeTest']! as String,
        userId: json['userId']! as int,
        numCorrect: json['numCorrect']! as int,
        numIncorrect: json['numIncorrect']! as int,
        timeComplete: json['timeComplete']! as int,
        topicId: json['topicId']! as int,
      );

  History copyWith({
    int? id,
    String? typeTest,
    int? numCorrect,
    int? numIncorrect,
    String? createdAt,
    int? timeComplete,
    int? topicId,
    int? userId,
  }){
    return History(id: id ?? this.id, typeTest: typeTest ?? this.typeTest, numCorrect: numCorrect ?? this.numCorrect, numIncorrect: numIncorrect ?? this.numIncorrect
        , createdAt: createdAt ?? this.createdAt, timeComplete: timeComplete ?? this.timeComplete, topicId: topicId ?? this.topicId, userId: userId ?? this.userId);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'typeTest' : typeTest,
      'numCorrect' : numCorrect,
      'numIncorrect' : numIncorrect,
      'createdAt' : createdAt,
      'timeComplete' : timeComplete,
      'topicId' : topicId,
      'userId' : userId,
    };
  }

  factory History.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return History.fromJson(data);
  }

}