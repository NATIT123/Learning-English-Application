import 'dart:ffi';

import 'package:sqflite/sqflite.dart';

import '../../dto/Topic.dart';
import 'DataBaseService.dart';

class TopicDatabase{
  final tableName="topics";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "name" NVARCHAR NOT NULL,
      "isPublic" INTEGER NOT NULL,
      "createdAt" TIMESTAMP NOT NULL,
      "progress" INTEGER NOT NULL,
      "userId" INTEGER NOT NULL,
       FOREIGN KEY(userId) REFERENCES topics(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required String name,required bool isPublic,required String createdAt,required int userId,required int progress}) async{
    final database=await DataBaseService().database;
    var isPublic0=isPublic?1:0;
    return await database?.rawInsert(
      '''INSERT INTO $tableName (name,isPublic,createdAt,userId,progress) VALUES (?,?,?,?,?)''',[name,isPublic0,createdAt,userId,progress],
    );


  }

  Future<List<Topic>?> fetchAll() async{
    final database=await DataBaseService().database;
    final topics=await database?.rawQuery(
      '''SELECT * from $tableName ORDER BY createdAt DESC '''
    );
    print(topics);
    return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }

  Future<Topic> fetchById(Long id)async{
    final database=await DataBaseService().database;
    final topic=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return Topic.fromSqfLiteDatabase(topic!.first);
  }

  Future<int?> update({required int id,String? name,int? progress}) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(name!=null) 'name':name,
      if(progress!=null) 'progress':progress


    },where: 'id = ?',
    conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE id = ?''',[id]);
  }

  Future<List<Topic>?> fetchByPublic(int public)async{
    final database=await DataBaseService().database;
    final topics=await database?.rawQuery('''SELECT * FROM $tableName WHERE isPublic = ?''',[public]);
    print(topics);
    return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }

  Future<List<Topic>?> fetchByUserId(int userId)async{
    final database=await DataBaseService().database;
    final topics=await database?.rawQuery('''SELECT * FROM $tableName WHERE userId = ? ''',[userId]);
    print(topics);
    return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }

  Future<List<Topic>?> fetchByPublicAndUser(int public,int userId)async{
    final database=await DataBaseService().database;
    final topics=await database?.rawQuery('''SELECT * FROM $tableName WHERE isPublic = ?  OR userId = ?''',[public,userId]);
    print(topics);
    return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }







  Future<List<Topic>?> fetchByPublicSearch(String topicName,int public)async{
    final database=await DataBaseService().database;
      final topics=await database?.rawQuery('''SELECT * FROM $tableName WHERE name LIKE ? AND  isPublic = ?''',['%$topicName%', public]);
      print(topics);
      return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }



}