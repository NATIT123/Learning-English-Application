import 'dart:convert';

import 'package:finalapp/Service/Firebase/FolderDatabaseRef.dart';
import 'package:finalapp/Views/FolderSet.dart';
import 'package:finalapp/Views/StudySet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Service/Sqlite/FolderDatabase.dart';
import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Folder.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';

class Library extends StatefulWidget {
  Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with TickerProviderStateMixin {

  var index=0;

  late final TabController _tabController;

  final folderDatabase=FolderDatabase();

  final topicDatabase=TopicDatabase();

  final vocabDatabase=VocabDatabase();

  final userDatabase=UserDatabase();

  final _formKey=GlobalKey<FormState>();

  FolderDatabaseRef folderDatabaseRef=FolderDatabaseRef();

  var nameFolder='';

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

  late Future<List<Folder>?> futureFolders;

  late Future<List<Topic>?> futureTopics;


  var message='';

  var userList=[];

  var listCount=[];


  FocusNode focusNode=FocusNode();
  void fetchFolders () async{
    List<UserDetail> _userList = [];
    var data=folderDatabase.fetchAll(currentUser==null?0:currentUser.id, 0);
    setState(() {
      futureFolders=data;
    });
    var dataUser;
    try {
      var dataFolder = await data;
      print(dataFolder?.length);
      if(dataFolder!=null){
        for(var data in dataFolder){
          dataUser= await userDatabase.fetchById(data.userId);
          _userList.add(dataUser);
        }
      }
    }catch(err){
      print(err);
    }

    setState(() {
      userList=_userList;
    });
  }
  Future<int?> getLength(int topicId)async{
    var x= await vocabDatabase.getLength(topicId);
    return x;
  }

  void fetchTopics() async {
    var _listCount=[];
    var _userList=[];
    var dataUser;
    var dataT=topicDatabase.fetchByPublic(1);
    setState(() {
      futureTopics=dataT;
    });
    var data=await dataT;
    try{
      if(data!=null){
        for(var dataTopic in data){
          int? length = await getLength(dataTopic.id);
          _listCount.add(length!);
          dataUser=await userDatabase.fetchById(dataTopic.userId);
          _userList.add(dataUser);
        }
      }
    }catch(err){
      print(err);
    }
    setState(() {
      listCount=_listCount;
      userList=_userList;
    });
  }

  var id;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchTopics();
    fetchFolders();
    _tabController = TabController(length: 2, vsync: this,initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
            controller:_tabController ,
            tabs: const [
          Tab(
            text: 'Học phần',
          ),
          Tab(
            text: 'Thư mục',
          )
        ]),
        title: const Text('Thư viện',style: TextStyle(
          fontWeight: FontWeight.bold,fontSize: 25,color: Colors.black
        ),),
        actions: [
         IconButton(
           iconSize: 30,
           onPressed:()async{
             if(_tabController.index==0){
               final result=await Navigator.pushNamed(context,'/createTopic',arguments: null);
               if(result!=null){
                 fetchTopics();
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
             }
             else if(_tabController.index==1){
               showDialog(context: context, builder: (context)=>_buildDialogAdd(context));

             }
         }, icon: const Icon(Icons.add),)
        ],
      ),
      body:TabBarView(
          controller: _tabController,
          children: [
        StudySet(),
        FolderSet()
      ])
    );
  }

  Widget _buildDialogAdd(BuildContext context){
    int? user;
    return AlertDialog(
      title:const Text('Tạo thư mục') ,
      content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  focusNode: focusNode,
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: 'Tên thư mục',
                  ),
                  validator: (String ?value){
                    if(value==null||value.isEmpty){
                      return "Vui lòng nhập tên thư mục";
                    }
                    return null;
                  },

                  onSaved: (String? value){
                    nameFolder=value??'';
                  },


                ),

                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Mô tả (tùy chọn)',
                  ),
                ),
              ]
          )
      ),
      actions: [
        TextButton(onPressed: ()=>{
          Navigator.pop(context),
        }, child: const Text('Hủy',style: TextStyle(
          color: Colors.black
        ),)
        ),
        TextButton(onPressed: () async=>{
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save(),
            id=await folderDatabase.create(name: nameFolder, isDelete: false, userId: currentUser.id),
            if(id==null){
              id=await folderDatabase.create(name: nameFolder, isDelete: false, userId: currentUser.id),
            },
            await folderDatabaseRef.addFolder(Folder(id: id, name: nameFolder, isDelete: false, userId: currentUser.id)),
            fetchFolders(),
            Navigator.pop(context),
            ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content:
            const Center(child:Text('Add Folder Successfully',)),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
            textColor: Colors.red,
            label:'Undo',
            onPressed: (){

            },
            ),
            )
            ),

          }
        },
            child: const Text('Xác nhận',style: TextStyle(
                color: Colors.black
            ),)
        )
      ],
    );
  }



}


