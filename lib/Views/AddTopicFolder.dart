import 'dart:convert';

import 'package:finalapp/Service/Firebase/FolderDatabaseRef.dart';
import 'package:finalapp/Service/Firebase/FolderTopicDatabaseRef.dart';
import 'package:finalapp/Service/Sqlite/FolderDatabase.dart';
import 'package:finalapp/Service/Sqlite/FolderTopicDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:finalapp/dto/FolderTopic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/Folder.dart';
import '../dto/UserDetail.dart';

class AddTopicFolder extends StatefulWidget {
  var topic;
  AddTopicFolder({super.key,required this.topic});

  @override
  State<AddTopicFolder> createState() => _AddTopicFolderState();
}

class _AddTopicFolderState extends State<AddTopicFolder> {

  var userList=[];

  final folderDatabase=FolderDatabase();
  final userDatabase=UserDatabase();
  final folderTopicDatabase=FolderTopicDatabase();

  FolderTopicDatabaseRef folderTopicDatabaseRef=FolderTopicDatabaseRef();

  FolderDatabaseRef folderDatabaseRef=FolderDatabaseRef();

  final _formKey=GlobalKey<FormState>();
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

  FocusNode focusNode=FocusNode();

  var listCheck=[];

  var listFolder=[];

  late Future<List<Folder>?> futureFolder;


  void fetchFolders () async{
    var data=folderDatabase.fetchAll(1, 0);
    setState(() {
      futureFolder=data;
    });
    List<UserDetail> _userList = [];
    var _listCheck=[];
    var _listFolder=[];
    var dataUser;
    try {
      var dataFolder = await data;
      var dataFolderTopic=await folderTopicDatabase.fetchAll();
      if(dataFolder!=null) {
        if(dataFolderTopic!=null){
          if(dataFolderTopic.isEmpty){
            _listCheck = List.generate(dataFolder.length, (index) => false);
          }
        }
        for (var _dataFolder in dataFolder) {
          _listFolder.add(_dataFolder);
          dataUser = await userDatabase.fetchById(_dataFolder.userId);
          _userList.add(dataUser);
          if (dataFolderTopic != null) {
            if (dataFolderTopic.isNotEmpty) {
              bool check=false;
              for (var data in dataFolderTopic) {
                if (data.topicId == widget.topic.id&&_dataFolder.id==data.folderId) {
                  check=true;
                  break;
                }
              }
              !check?_listCheck.add(false):_listCheck.add(true);
            }
          }
        }
      }
    }catch(err){
      print(err);
    }

    setState(() {
      userList=_userList;
      listCheck=_listCheck;
      listFolder=_listFolder;
    });
    print(listCheck);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchFolders();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Thêm vào thư mục',style: TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold
        ),),
        actions: [
          IconButton(onPressed: ()async{
            for(var data in listFolder){
              await folderTopicDatabase.deleteByTopicAndFolder(widget.topic.id,data.id);
              await folderTopicDatabaseRef.deleteTopicAndFolder(data.id,widget.topic.id);
            }
             for(int i=0;i<listCheck.length;i++){
               if(listCheck[i]){
                 var data=await folderTopicDatabase.create(isDelete: listFolder[i].isDelete, topicId: widget.topic.id, folderId:listFolder[i].id);
                 data??await folderTopicDatabase.create(isDelete: listFolder[i].isDelete, topicId: widget.topic.id, folderId:listFolder[i].id);
                 await folderTopicDatabaseRef.addFolderTopic(FolderTopic(id: data??0, isDeleted: listFolder[i].isDelete, topicId: widget.topic.id, folderId: listFolder[i].id));
            }
             }
             Navigator.pop(context);
             Navigator.pop(context,'Học phần đã được thêm');
          }, icon: const Icon(Icons.check))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: TextButton(
                child: const Text('Tạo thư mục mới',style: TextStyle(
                    color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 15
                ),),
                onPressed: (){
                  showDialog(context: context, builder: (context)=>_buildDialogAdd(context));
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child:_buildItem(context))
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context){
    return FutureBuilder<List<Folder>?>(
        future:futureFolder,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else{
            if(snapshot.data==null||snapshot.data!.isEmpty){
              return const Center(
                child: Text('No Folders.....',style: TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30
                ),),
              );
            }
            else{
              final folders=snapshot.data!;
              return ListView.separated(itemBuilder: (context,index)=>const SizedBox(
                height: 12,
              ),separatorBuilder: (context,index)=>
                  InkWell(
                    onTap: ()async{
                      setState(() {
                        listCheck[index]=!listCheck[index];
                      });
                    },
                  child:Card(
                color:index<listCheck.length&&listCheck.isNotEmpty&&listCheck[index]?Colors.blue.shade200:Colors.white,
                    child:Container(
                      padding:const EdgeInsets.all(10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.folder,size: 15,),
                            const SizedBox(height: 15,),
                            Text(folders[index].name,style: const TextStyle(
                                color: Colors.grey,fontSize: 12,fontWeight: FontWeight.bold
                            ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                userList.isNotEmpty&&index<userList.length?convertImage(userList[index].imgPath.toString()):const Text(''),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(userList.isNotEmpty?userList[index].userName.toString():'',style: const TextStyle(
                                    color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                                ),),
                              ],
                            )
                          ]
                      ),
                    ),
                  )
              ) , itemCount: folders!.length+1);
            }
          }
        }
    );
  }

  Widget _buildDialogAdd(BuildContext context){
    int? data;
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
                    // enabledBorder: ,
                    // disabledBorder: ,
                    // focusedBorder: ,
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

            data=await folderDatabase.create(name: nameFolder, isDelete: false, userId: currentUser.id),
            data??await folderDatabase.create(name: nameFolder, isDelete: false, userId: currentUser.id),
            await folderDatabaseRef.addFolder(Folder(id: data??0, name: nameFolder, isDelete: false, userId: currentUser.id)),

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
              )

          }
        },
            child: const Text('Xác nhận',style: TextStyle(
                color: Colors.black
            ),)
        )
      ],
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
