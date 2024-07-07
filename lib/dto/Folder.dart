
import 'package:cloud_firestore/cloud_firestore.dart';

class Folder{
  int id;
  String name;
  bool isDelete;
  int userId;

  Folder({required this.id,required this.name,required this.isDelete,required this.userId});

  factory Folder.fromSqfLiteDatabase(Map<String,dynamic> map)=>Folder(
    id:map['id']?.toInt()??0,
    name:  map['name']??'',
    isDelete: map['isDelete']==1?true:false,
    userId: map['userId']?.toInt()??0,

  );

  Folder.fromJson(Map<String, Object?> json) :
        this(
        id: json['id']! as int,
        name: json['name']! as String,
        isDelete: json['isDelete']! as bool,
        userId: json['userId']! as int,
      );

  Folder copyWith({
    int? id,
    String? name,
    bool? isDelete,
    int? userId,
  }){
    return Folder(id: id ?? this.id, name: name ?? this.name, isDelete: isDelete ?? this.isDelete, userId: userId ?? this.userId);
  }

  Map<String, Object?> toJson(){
    return {
      'id' : id,
      'name' : name,
      'isDelete' : isDelete,
      'userId' : userId,
    };
  }

  factory Folder.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data=document.data()!;
    return Folder.fromJson(data);
  }

}