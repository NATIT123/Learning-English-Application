

import 'package:finalapp/Service/Sqlite/DataBaseService.dart';
import 'package:sqflite/sqflite.dart';


import '../../dto/Vocab.dart';

class VocabDatabase{
  final tableName="vocabs";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "en" NVARCHAR NOT NULL,
      "vi" NVARCHAR NOT NULL,
      "isMark" INTEGER NOT NULL,
      "topicId" INTEGER NOT NULL,
      "countStudy" INTEGER NOT NULL,
      FOREIGN KEY(topicId) REFERENCES topics(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required String en,required String vi,required int topicId,required bool isMark,required int countStudy}) async{
    final database=await DataBaseService().database;
    var isMark0=isMark?1:0;
    return await database?.rawInsert(
      '''INSERT INTO $tableName (en,vi,topicId,isMark,countStudy) VALUES (?,?,?,?,?)''',[en,vi,topicId,isMark0,countStudy],
    );
  }

  Future<List<Vocab>?> fetchAll() async{
    final database=await DataBaseService().database;
    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName'''
    );
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }


  Future<Vocab> fetchById(int id)async{
    final database=await DataBaseService().database;
    final vocab=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return Vocab.fromSqfLiteDatabase(vocab!.first);
  }

  Future<int?> update({required int id,String? en,String? vi,bool? isMark,int? countStudy}) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(en!=null) 'en':en,
      if(vi!=null) 'vi':vi,
      if(isMark!=null) 'isMark':isMark,
      if(countStudy!=null)  'countStudy':countStudy

    },where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<List<Vocab>?> fetchAllWithTopic(int id) async{
    final database=await DataBaseService().database;
    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? ''',[id]
    );
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }

  Future<List<Vocab>?> fetchAllWithTopicWithMark(int id,bool isMark) async{
    final database=await DataBaseService().database;
    int isMarked=isMark?1:0;
    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? AND v.isMark = ? ''',[id,isMarked]
    );
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }

  Future<List<Vocab>?> fetchAllWithTopicRandom(int id) async{
    final database=await DataBaseService().database;
    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? ORDER BY RANDOM()''',[id]
    );
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }

  Future<List<Vocab>?> fetchAllWithTopicRandomWithChoice(int id,int index) async{
    final database=await DataBaseService().database;
    final x=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? ''',[id]
    );

    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? LIMIT 4 OFFSET $index ''',[id]
    );
    print(vocabs);
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }

  Future<List<Vocab>?> fetchAllWithTopicShuffleMarked(int id) async{
    final database=await DataBaseService().database;
    final vocabs=await database?.rawQuery(
        '''SELECT * from $tableName v WHERE v.topicId = ? AND isMark = 1 ''',[id]
    );
    return vocabs?.map((vocab)=>Vocab.fromSqfLiteDatabase(vocab)).toList();
  }





  Future<void> delete(int id) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE id = ?''',[id]);
  }

  Future<void> deleteVocab(int topicId) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE topicId = ?''',[topicId]);
  }

  Future<int?> getLength(int topicId)async{
    final database=await DataBaseService().database;
    var x = await database?.rawQuery('SELECT COUNT (*) from $tableName WHERE topicId = ?',[topicId]);
    int? count = Sqflite.firstIntValue(x!);
    return count;
  }

  Future<int?> getLengthMarked(int topicId)async{
    final database=await DataBaseService().database;
    var x = await database?.rawQuery('SELECT COUNT (*) from $tableName WHERE topicId = ? AND isMark=1',[topicId]);
    int? count = Sqflite.firstIntValue(x!);
    return count;
  }
}