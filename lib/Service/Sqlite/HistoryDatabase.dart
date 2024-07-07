import 'dart:ffi';

import 'package:finalapp/dto/History.dart';
import 'package:sqflite/sqflite.dart';

import 'DataBaseService.dart';


class HistoryDatabase{
  final tableName="history";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "typeTest" NVARCHAR NOT NULL,
      "numCorrect" INTEGER NOT NULL,
      "numIncorrect" INTEGER NOT NULL,
      "timeComplete" INTEGER NOT NULL,
      "createdAt" TIMESTAMP NOT NULL,
      "topicId" INTEGER NOT NULL, 
      "userId" INTEGER NOT NULL,
      FOREIGN KEY(userId) REFERENCES users(id),
      FOREIGN KEY(topicId) REFERENCES topics(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required String typeTest,required int numCorrect,required int numIncorrect,required int timeComplete,required int topicId,required userId,required String createdAt}) async{
    final database=await DataBaseService().database;
    return await database?.rawInsert(
      '''INSERT INTO $tableName (typeTest,numCorrect,numIncorrect,timeComplete,topicId,userId,createdAt) VALUES (?,?,?,?,?,?,?)''',[typeTest,numCorrect,numIncorrect,timeComplete,topicId,userId,createdAt],
    );

  }

  Future<List<History>?> fetchAll() async{
    final database=await DataBaseService().database;
    final histories=await database?.rawQuery(
        '''SELECT * from $tableName'''
    );
    print(histories);
    return histories?.map((history)=>History.fromSqfLiteDatabase(history)).toList();
  }

  Future<History> fetchById(Long id)async{
    final database=await DataBaseService().database;
    final history=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return History.fromSqfLiteDatabase(history!.first);
  }

  Future<List<History>?> fetchByTypeTest(int topicId,String typeTest)async{
    final database=await DataBaseService().database;
    final histories=await database?.rawQuery('''SELECT DISTINCT  * FROM $tableName  WHERE topicId = ? AND typeTest = ? AND numIncorrect = 0 ORDER BY timeComplete ASC ''',[topicId,typeTest]);
    return histories?.map((history)=>History.fromSqfLiteDatabase(history)).toList();
  }



  Future<int?> update({required int id, required String? typeTest,required int? numCorrect,required int? numIncorrect,required int? timeComplete,required int? topicId,required int? userId,required String createdAt}) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(typeTest!=null) 'typeTest':typeTest,
      if(numCorrect!=null) 'numCorrect':numCorrect,
      if(numIncorrect!=null) 'numIncorrect':numIncorrect,
      if(timeComplete!=null) 'timeComplete':timeComplete,
      if(userId!=null) 'userId':userId,
      if(topicId!=null) 'topicId':topicId,
      if(createdAt!=null) 'createdAt':createdAt,
    },where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE id = ?''',[id]);
  }


}