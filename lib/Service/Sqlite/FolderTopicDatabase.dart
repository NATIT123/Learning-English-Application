
import 'package:sqflite/sqflite.dart';


import '../../dto/FolderTopic.dart';

import '../../dto/Topic.dart';
import 'DataBaseService.dart';

class FolderTopicDatabase{
  final tableName="FolderWithTopic";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "isDelete" INTEGER NOT NULL DEFAULT 0,
      "topic_id" INTEGER NOT NULL,
      "folder_id" INTEGER NOT NULL,
      FOREIGN KEY(topic_id) REFERENCES topics(id),
      FOREIGN KEY(folder_id) REFERENCES folders(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required bool isDelete,required int topicId,required int folderId}) async{
    final database=await DataBaseService().database;
    return await database?.rawInsert(
          '''INSERT INTO $tableName (isDelete,topic_id,folder_id) VALUES (?,?,?)''',[isDelete,topicId,folderId]);
  }

  Future<List<FolderTopic>?> fetchAll() async{
    final database=await DataBaseService().database;
    final folderWithTopic=await database?.rawQuery(
        '''SELECT * from $tableName'''
    );
    print(folderWithTopic);
    return folderWithTopic?.map((folderWithTopics)=>FolderTopic.fromSqfLiteDatabase(folderWithTopics)).toList();
  }

  Future<List<Topic>?> fetchAllWithFolder(int folderId) async{
    final database=await DataBaseService().database;
    final topics=await database?.rawQuery(
        '''SELECT t.id,t.name,t.isPublic,t.createdAt,t.userId,t.progress from topics t JOIN $tableName ft ON t.id = ft.topic_id WHERE ft.folder_id = ? ''',[folderId]);
    print('All:$topics');
    return topics?.map((topic)=>Topic.fromSqfLiteDatabase(topic)).toList();
  }

  Future<FolderTopic> fetchById(int id)async{
    final database=await DataBaseService().database;
    final folderWithTopic=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return FolderTopic.fromSqfLiteDatabase(folderWithTopic!.first);
  }

  Future<int?> update({required int id,String? en,String? vi}) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(en!=null) 'en':en,
      if(vi!=null) 'vi':vi,

    },where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int folderId) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE folder_id = ?''',[folderId]);
  }

  Future<void> deleteByTopicAndFolder(int topicId,int folderId) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE topic_id = ? AND folder_id = ?''',[topicId,folderId]);
  }



  Future<int?> getLength(int folderId)async{
    final database=await DataBaseService().database;
    var row= await database?.rawQuery('SELECT COUNT (*) from $tableName');
    int? countRow=Sqflite.firstIntValue(row!);
    if(countRow==0){
      return 0;
    }
    var x = await database?.rawQuery('SELECT COUNT (*) from $tableName WHERE folder_id = ?',[folderId]);
    int? count = Sqflite.firstIntValue(x!);
    return count;
  }



}