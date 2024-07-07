import 'dart:ffi';

import 'package:sqflite/sqflite.dart';

import '../../dto/Folder.dart';
import 'DataBaseService.dart';

class FolderDatabase{
  final tableName="folders";

  Future<void> createTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "name" NVARCHAR NOT NULL,
      "isDelete" INTEGER NOT NULL,
      "userId" INTEGER NOT NULL,
       FOREIGN KEY(userId) REFERENCES folders(id),
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int?> create({required String name,required bool isDelete,required int userId}) async{
    final database=await DataBaseService().database;
    var isDelete0=isDelete?1:0;
    return await database?.rawInsert(
      '''INSERT INTO $tableName (name,isDelete,userId) VALUES (?,?,?)''',[name,isDelete0,userId],
    );
  }

  Future<List<Folder>?> fetchAll(int userId,int status) async{
    final database=await DataBaseService().database;
    final folders=await database?.rawQuery(
        '''SELECT * FROM $tableName WHERE isDelete = ? AND userId = ? ''',[status,userId]
    );
    return folders?.map((folder)=>Folder.fromSqfLiteDatabase(folder)).toList();
  }

  Future<Folder> fetchById(int id)async{
    final database=await DataBaseService().database;
    final folder=await database?.rawQuery('''SELECT * FROM $tableName WHERE id = ?''',[id]);
    return Folder.fromSqfLiteDatabase(folder!.first);
  }

  Future<int?> update({required int id,required String name,required bool isDelete}) async{
    final database=await DataBaseService().database;
    return await database?.update(tableName, {
      if(name!=null) 'name':name,
      if(isDelete!=null) 'isDelete':isDelete?true:false
    },where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async{
    final database=await DataBaseService().database;
    await database?.rawDelete('''DELETE FROM $tableName WHERE id = ?''',[id]);
  }

  Future<List<Folder>?> fetchByStatus(int status)async{
    final database=await DataBaseService().database;
    final folders=await database?.rawQuery('''SELECT * FROM $tableName WHERE isDelete = ?''',[status]);
    return folders?.map((folder)=>Folder.fromSqfLiteDatabase(folder)).toList();
  }



}