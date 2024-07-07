
import 'package:finalapp/Service/Sqlite/DataBaseService.dart';
import 'package:sqflite/sqflite.dart';


import '../../dto/FolderTopic.dart';
import '../../dto/Topic.dart';
import '../../dto/UserVocab.dart';

class UserVocabDatabase{
  final tableName="UserWithVocab";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "statusStudy" NVARCHAR NOT NULL ,
      "numStudy" INTEGER NOT NULL,
      "valueTrue" INTEGER NOT NULL,
      "vocabId" INTEGER NOT NULL,
      "userId" INTEGER NOT NULL,
      FOREIGN KEY(vocabId) REFERENCES vocabs(id),
      FOREIGN KEY(userId) REFERENCES users(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required String statusStudy,required int vocabId,required int userId,required int numStudy,required int valueTrue}) async{
    final database=await DataBaseService().database;
    return await database?.rawInsert(
      '''INSERT INTO $tableName (statusStudy,vocabId,userId,numStudy,valueTrue) VALUES (?,?,?,?,?)''',[statusStudy,vocabId,userId,numStudy,valueTrue],
    );
  }

  Future<List<UserVocab>?> fetchAll() async{
    final database=await DataBaseService().database;
    final userVocabs=await database?.rawQuery(
        '''SELECT * from $tableName'''
    );
    print(userVocabs);
    return userVocabs?.map((userVocab)=>UserVocab.fromSqfLiteDatabase(userVocab)).toList();
  }



  Future<UserVocab> fetchById(int id)async{
    final database=await DataBaseService().database;
    final userVocab=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return UserVocab.fromSqfLiteDatabase(userVocab!.first);
  }

  Future<UserVocab?> fetchByUserIdAndVocabId(int userId,int vocabId)async{
    final database=await DataBaseService().database;
    final userVocab=await database?.rawQuery('''SELECT * FROM $tableName WHERE userId = ? AND vocabId = ? ''',[userId,vocabId]);

    if(userVocab!.isEmpty) return null;
    return UserVocab.fromSqfLiteDatabase(userVocab!.first);
  }

  Future<int?> update({required int id,String? statusStudy,int? numStudy,int? valueTrue }) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(statusStudy!=null) 'statusStudy':statusStudy,
      if(numStudy!=null) 'numStudy':numStudy,
      if(valueTrue!=null) 'valueTrue':valueTrue

    },where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int folderId) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE folder_id = ?''',[folderId]);
  }

  Future<void> deleteByUserIdAndVocabId(int userId,int vocabId) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE userId = ? AND vocabId = ?''',[userId,vocabId]);
  }



}