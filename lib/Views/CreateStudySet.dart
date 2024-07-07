
import 'dart:convert';
import 'dart:typed_data';

import 'package:finalapp/Service/Firebase/FolderDatabaseRef.dart';
import 'package:finalapp/Service/Firebase/FolderTopicDatabaseRef.dart';
import 'package:finalapp/Service/Sqlite/FolderDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:finalapp/dto/FolderTopic.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Sqlite/FolderTopicDatabase.dart';
import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Folder.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';
import '../dto/Vocab.dart';

class CreateStudySet extends StatefulWidget {
  var folder;
  CreateStudySet({super.key,required this.folder});

  @override
  State<CreateStudySet> createState() => _CreateStudySetState();
}

class _CreateStudySetState extends State<CreateStudySet> {

  final topicDatabase=TopicDatabase();

  final vocabDatabase=VocabDatabase();

  final folderWithTopicDatabase=FolderTopicDatabase();

  final folderDatabase=FolderDatabase();

  FolderDatabaseRef folderDatabaseRef=FolderDatabaseRef();

  late Future<List<Topic>?> futureTopics;

  late Future<List<Vocab>?> futureVocabs;

  late Future<List<FolderTopic>?> futureFolderTopic;

  var listCheck=[];

  var listCount=[];

  var nameFolder='';

  FolderTopicDatabaseRef folderTopicDatabaseRef=FolderTopicDatabaseRef();

  final _formKey=GlobalKey<FormState>();

  FocusNode focusNode=FocusNode();

  var currentUser;
  late SharedPreferences prefs;

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
    }
  }

  var message='';

  final userDatabase=UserDatabase();

  var userList=[];

  void fetchTopic()async{
    await getSharedPreferences();
    var data=topicDatabase.fetchByPublicAndUser(1,currentUser==null?0:currentUser.id);
    setState(() {
      futureTopics=data;
    });
    var rowLength=0;
    var _listCount=[];
    var _listCheck=[];
    var _userList=[];
    var dataUser;
    var listTopic=[];
    var topic=await data;
    if(topic!=null){
      rowLength=topic.length;
      for(var dataTopic in topic){
        listTopic.add(dataTopic);
        int? length = await getLength(dataTopic.id);
        _listCount.add(length);
        dataUser=await userDatabase.fetchById(dataTopic.userId);
        print(dataTopic.userId);
        _userList.add(dataUser);
      }
    }

    var dataTopicFolder = await folderWithTopicDatabase.fetchAll();
    if(topic!=null) {
      if (dataTopicFolder != null) {
        if (dataTopicFolder.isEmpty) {
          _listCheck = List.generate(rowLength, (index) => false);
        }
      }
      for(var dataTopic in topic){
        if(dataTopicFolder!=null){
          if(dataTopicFolder.isNotEmpty){
            bool check=false;
            for(var data in dataTopicFolder){
              if(data.folderId==widget.folder.id &&dataTopic.id==data.topicId){
                check=true;
                break;
              }
            }
            !check?_listCheck.add(false):_listCheck.add(true);
          }
        }
      }
    }
    setState(() {
      userList=_userList;
      listCount=_listCount;
      listCheck=_listCheck;
    });
    print(userList);
  }

  Future<int?> getLength(int topicId)async{
    var x= await vocabDatabase.getLength(topicId);
    return x;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchTopic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm học phần',style: TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20
        ),),
        actions: [
          IconButton(onPressed: ()async{
            await folderWithTopicDatabase.delete(widget.folder.id);
            await folderTopicDatabaseRef.deleteFolderTopic(widget.folder.id);
            try{
              var dataTopic=await topicDatabase.fetchByPublicAndUser(1,currentUser.id);
              if(dataTopic!=null){
                for(var i=0;i<dataTopic.length;i++){
                  if(listCheck[i]){
                    var data=await folderWithTopicDatabase.create(isDelete: widget.folder.isDelete, topicId: dataTopic[i].id, folderId: widget.folder.id);
                    data ??= await folderWithTopicDatabase.create(isDelete: widget.folder.isDelete, topicId: dataTopic[i].id, folderId: widget.folder.id);
                    await folderTopicDatabaseRef.addFolderTopic(FolderTopic(id: data??0, isDeleted: widget.folder.isDelete, topicId: dataTopic[i].id, folderId: widget.folder.id));
             }
             }
              }
            }catch(err){
              print(err);
            }
            Navigator.pop(context);
            Navigator.pop(context,'Add Topic Folder Successfully');
          }, icon: const Icon(Icons.check))
        ],
      ),
      body:Column(
        children: [
          Center(
            child: TextButton(
              child: const Text('Tạo học phần mới',style: TextStyle(
                  color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 15
              ),),
              onPressed: ()async{
                final result=await Navigator.pushNamed(context,'/createTopic',arguments: null);
                if(result!=null){
                  fetchTopic();
                  setState(() {
                    message=result.toString();
                  });
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content:
                    Center(child:Text(message,)),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        textColor: Colors.red,
                        label:'Undo',
                        onPressed: (){

                        },
                      ),
                    )
                    );
                }
              },
            ),
          ),
          Expanded(child:_buildFolder(context))
    ]
    )
    );
  }



  Widget _buildFolder(BuildContext context){
    return FutureBuilder<List<Topic>?>(
        future: topicDatabase.fetchByPublicAndUser(1,currentUser==null?0:currentUser.id),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
          }
          else{
          if(snapshot.data==null||snapshot.data!.isEmpty){
          return const Center(
          child: Text('No topics...',style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
            ),
            ),
            );
            }
            else{
            final topics=snapshot.data!;
            return ListView.separated(itemBuilder: (context,index)=>
              Card(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.all(20),
            child:InkWell(
              onTap: (){
                setState(() {
                  listCheck[index]=!listCheck[index];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color:listCheck.isNotEmpty&&index<listCheck.length&&listCheck[index]?Colors.yellow:Colors.white)
                ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topics[index].nameTopic,style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(listCount.isNotEmpty&&index<listCount.length?'${listCount[index].toString()} thuật ngữ':'',style: const TextStyle(
                    color: Colors.grey,fontSize: 15
                  ),),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading:  userList.isNotEmpty&&index<userList.length?convertImage(userList[index].imgPath.toString()):const Text(''),
                    title:  Text(userList.isNotEmpty&&index<userList.length?userList[index].userName.toString() :'',style: const TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
              ),),
                  )
                ],
              ),
            ),
            )
          ), separatorBuilder: (context,index)=>const SizedBox(
            height: 10,
          ), itemCount: topics.length);
          }
          }
          }
          );
  }

  Widget convertImage(image){
    return !image.contains("http") && !image.contains("images")
        ? CircleAvatar(
      radius: 20,
      backgroundImage: MemoryImage(convertStringToUint8List(image)),
    )
        : CircleAvatar(
      radius: 20,
      child: ClipOval(
          child: image.contains("http")
              ? Image.network(image)
              : Image.asset(image)
      ),
    );
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }


}
