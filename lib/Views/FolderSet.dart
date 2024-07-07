import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Firebase/FolderDatabaseRef.dart';
import '../Service/Firebase/TopicDatabaseRef.dart';
import '../Service/Sqlite/FolderDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../dto/Folder.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';
class FolderSet extends StatefulWidget {

  const FolderSet({super.key});

  @override
  State<FolderSet> createState() => _FolderSetState();
}

class _FolderSetState extends State<FolderSet> {


  final folderDatabase=FolderDatabase();

  final _formKey=GlobalKey<FormState>();

  final userDatabase=UserDatabase();

  FolderDatabaseRef folderDatabaseRef=FolderDatabaseRef();

  var nameFolder='';

  FocusNode focusNode=FocusNode();

  late Future<List<Folder>?> futureFolders;

  var message='';

  var userList=[];

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


  void fetchFolders () async{
    await getSharedPreferences();
    List<UserDetail> _userList = [];
    var data=folderDatabase.fetchAll(currentUser==null?0:currentUser.id, 0);
    setState(() {
      futureFolders=data;
    });
    var dataUser;
    try {
      var dataFolder = await data;
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

  var id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchFolders();
    focusNode.requestFocus();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(10),
          child:FutureBuilder<List<Folder>?>(
          future:folderDatabase.fetchAll(currentUser==null?0:currentUser.id, 0),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }
            else{
              if(snapshot.data==null||snapshot.data!.isEmpty){
                return SingleChildScrollView(child:_buildEmpty(context));
              }
              else{
                final folders=snapshot.data!;
                return ListView.separated(itemBuilder: (context,index)=>const SizedBox(
                  height: 12,
                ),separatorBuilder: (context,index)=>Card(
                  color: Colors.white,
                  child:
                  InkWell(
                    onTap: ()async{
                      final value=await Navigator.pushNamed(context,'/detailsFolder',arguments:folders[index]);
                      fetchFolders();
                      if(value!=null){
                        setState(() {
                          message=value as String;
                        });
                        // ScaffoldMessenger.of(context)
                        //   ..removeCurrentSnackBar()
                        //   ..showSnackBar(SnackBar(content:
                        //   Center(child:Text(message,)),
                        //     duration: const Duration(seconds: 2),
                        //     action: SnackBarAction(
                        //       textColor: Colors.red,
                        //       label:'Undo',
                        //       onPressed: (){
                        //
                        //       },
                        //     ),
                        //   )
                        //   );
                      }
                    },
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
                              Text(userList.isNotEmpty &&index< userList.length?userList[index].userName.toString():'',style: const TextStyle(
                                  color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                              ),),
                            ],
                          )
                        ]
                    ),
                  )
                  ) ,
                ) , itemCount: folders!.length+1);
              }
            }
          }
      )
      )

    );
  }

  Widget _buildEmpty(BuildContext context){
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          CachedNetworkImage(
            imageUrl: "https://w7.pngwing.com/pngs/763/637/png-transparent-directory-icon-folder-miscellaneous-angle-rectangle-thumbnail.png",
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          const SizedBox(height: 10,),
          const Center(child:Text('Sắp xếp học phần của bạn theo chủ đề, giáo viên, khóa học, v.v.',
            textAlign: TextAlign.center,
            style: TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
          ),)),
          const SizedBox(height: 10,),

          ElevatedButton(onPressed:()async=>{
            await showDialog(context: context, builder: (context)=>_buildDialogAdd(context)
            )
          },
              style: ElevatedButton.styleFrom(
                  shape:RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(
                      color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                  )
              ), child: const Text('Tạo thư mục',style: TextStyle(
                  color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold
              ),)
          )
        ],
      ),
    );
  }


  Widget _buildDialogAdd(BuildContext context){
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
          print(323),
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save(),
            id=await folderDatabase.create(name: nameFolder, isDelete: false, userId: currentUser.id),
            print('Test:$id'),
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
