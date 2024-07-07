import 'package:cloud_firestore/cloud_firestore.dart';

class Vocab{
  int id;
  String en;
  String vi;
  int topicId;
  bool isMark;
  int countStudy;

  Vocab({required this.id,required this.en,required this.vi,required this.topicId,required this.isMark,required this.countStudy});

  factory Vocab.fromSqfLiteDatabase(Map<String,dynamic> map)=>Vocab(
    id:map['id']?.toInt()??0,
    en: map['en']??'',
    vi: map['vi']??'',
    topicId: map['topicId']?.toInt()??0,
    isMark: map['isMark']==1?true:false,
    countStudy: map['countStudy']?.toInt()??0,
  );

  Vocab.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        en: json['en']! as String,
        vi: json['vi']! as String,
        topicId: json['topicId']! as int,
        isMark: json['isMark']! as bool,
        countStudy: json['countStudy']! as int,
      );

  Vocab copyWith({
    int? id,
    String? en,
    String? vi,
    int? topicId,
    bool? isMark,
    int? countStudy,
  }){
    return Vocab(id: id ?? this.id,en: en ?? this.en, vi: vi ?? this.vi, topicId: topicId ?? this.topicId
        , isMark: isMark ?? this.isMark, countStudy: countStudy ?? this.countStudy);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'en' : en,
      'vi' : vi,
      'topicId' : topicId,
      'isMark' : isMark,
      'countStudy' : countStudy,
    };
  }

  factory Vocab.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return Vocab.fromJson(data);
  }
}