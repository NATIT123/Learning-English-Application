import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/Firebase/FolderDatabaseRef.dart';
import '../Service/Sqlite/FolderDatabase.dart';
import '../Service/Sqlite/FolderTopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';
class DetailFolder extends StatefulWidget {

  var folder;
  DetailFolder({super.key,required this.folder});

  @override
  State<DetailFolder> createState() => _DetailFolderState();
}

class _DetailFolderState extends State<DetailFolder> {

  final _formKey=GlobalKey<FormState>();

  var nameFolder='';

  FocusNode focusNode=FocusNode();

  final folderDatabase=FolderDatabase();

  final folderTopicDatabase=FolderTopicDatabase();

  late Future<List<Topic>?> futureTopics;

  final vocabDatabase=VocabDatabase();




  var style=const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15
  );


  var message;

  var listCount=[];

  var countTopic=0;

  final userDatabase=UserDatabase();

  var userData;

  late Future<List<Topic>?> futureTopic;

  FolderDatabaseRef folderDatabaseRef=FolderDatabaseRef();




  void fetchFolder()async{
    var res=await folderDatabase.fetchById(widget.folder.id??0);
    setState(() {
      widget.folder=res;
    });
  }

  var userList=[];

  late SharedPreferences prefs;
  late UserDetail currentUser;

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
      print(currentUser.id);
    }
  }

  void fetchTopicFolder(int folderId)async {
    var _listCount=[];
    var _userList=[];
    var dataUser;
    var data=folderTopicDatabase.fetchAllWithFolder(folderId);
    setState(() {
      futureTopics=data;
    });
    try {
      var dataFolderTopic = await data;
      if(dataFolderTopic!=null){
        for(var data in dataFolderTopic){
          print(data.progress);
          int? length = await getLength(data.id);
          _listCount.add(length!);
          dataUser=await userDatabase.fetchById(data.userId);
          _userList.add(dataUser);
        }
      }
    }catch(err){
      print(err);
    }

    setState(() {
      userList=_userList;
      listCount=_listCount;
    });
  }

  void fetchUsers()async{
    print(widget.folder.id);
    var dataUser=await userDatabase.fetchById(widget.folder.userId);
    var list=await userDatabase.fetchAll();
    setState(() {
      userData=dataUser;
    });
  }

  Future<int?> getLength(int topicId)async{
    var x= await vocabDatabase.getLength(topicId);
    return x;
  }

  Future<int?> getLengthTopic(int folderId)async{
    var x= await folderTopicDatabase.getLength(folderId);
    print('LengthTopic:$x');
    setState(() {
      countTopic=x!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchUsers();
    fetchTopicFolder(widget.folder.id);
    getLengthTopic(widget.folder.id);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:IconButton(onPressed: (){
          Navigator.pop(context,'Success');
        }, icon: Icon(Icons.arrow_back_outlined)),
        title:const Text('Thư mục',style: TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert,size: 20,),
            onPressed: ()async{
              final result=await showDialog(context: context, builder: (context)=>Dialog.fullscreen(
                  child:_buildItemMore(context)
              )
              );
              if(result!=null){
                var dataFolder=await folderDatabase.fetchById(widget.folder.id??0);
                fetchTopicFolder(widget.folder.id);
                await getLengthTopic(widget.folder.id);
                setState(() {
                  message=result;
                  widget.folder=dataFolder;
                });
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content:
                  Center(child:Text(message.toString(),)),
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
          )
        ],
      ),
      body:Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _builderHeader(context),
          const SizedBox(
            height: 30,
          ),
          Expanded(child:_buildItem(context))
        ],
      ) ,
    );
  }

  Widget _builderHeader(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${countTopic.toString()} học phần',style:const TextStyle(
                color:Colors.grey,fontWeight:FontWeight.bold,
              )),
             const SizedBox(
               width: 20,
             ),
             Row(
               children: [
                 userData!=null?convertImage(userData.imgPath.toString()):const Text(''),
                 const SizedBox(
                   width: 10,
                 ),
                 Text(userData?.userName??'',style: const TextStyle(
                     color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                 ),),
               ],
             )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(widget.folder?.name??'',style: const TextStyle(
            color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold
          ),)
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context){
      return
        FutureBuilder<List<Topic>?>(
            future: futureTopics,
            builder: (context,snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _buildEmpty(context);
          }
          else {
            final topics = snapshot.data!;
            return
              ListView.separated(itemBuilder: (context,index)=>InkWell(
                onTap: ()async{
                  final _message=await Navigator.pushNamed(context,'/detailTopic',arguments: topics[index]);
                  if(_message!=null){
                   setState((){
                     message = _message;
                   });
                    fetchFolder();
                    fetchTopicFolder(widget.folder.id);
                  }
                },
                  child:Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child:
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topics[index].nameTopic, style: const TextStyle(
                          color: Colors.black, fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(
                        child:  listCount.isNotEmpty&&index<listCount.length?Text("${listCount[index].toString()} thuật ngữ",style: const TextStyle(
                            color: Colors.grey,fontSize: 12,fontWeight: FontWeight.bold
                        ),
                        ):const CircularProgressIndicator(
                          color: Colors.black,
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
                          Text(userList.isNotEmpty&&index<userList.length?userList[index].userName.toString() :'',style: const TextStyle(
                              color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                          ),),
                        ],
                      )
                    ],
                  ),
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 12,
                        animation: true,
                        percent:index>=listCount.length||listCount.isEmpty||index>=topics.length?0.0:topics[index].progress/listCount[index],
                        center:listCount.isEmpty||index>=listCount.length||index>=topics.length?const Text('0%'):Text('${((topics[index].progress/listCount[index])*100).toInt()}%'),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor:Colors.green,
                        backgroundColor: Colors.orange,
                      ),
                  ]
                  )
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

  Widget _buildItemMore(BuildContext context){
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              showDialog(context: context, builder: (context)=>_buildDialogEdit(context));
            },
          child:Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(
                width: 40,
              ),
              Text('Sửa',style: style,)
            ],
          ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: ()async{
              final message=Navigator.pushNamed(context, "/createStudySet",arguments: widget.folder);
              if(message!=null){
                print(message);
              }
            },
          child:Row(
            children: [
              const Icon(Icons.add),
              const SizedBox(
                width: 40,
              ),
              Text('Thêm học phần',style: style)
            ],
          ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Icon(Icons.share),
              const SizedBox(
                width: 40,
              ),
              Text('Chia sẻ',style: style)
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: (){
              showDialog(context: context, builder: (context)=>_buildAlertDialog(context));
            },
          child:Row(
            children: [
              const Icon(Icons.delete),
              const SizedBox(
                width: 40,
              ),
              Text('Xóa',style: style)
            ],
          ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy',style: style,),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child:
      Column(
        mainAxisSize: MainAxisSize.max,
    children: [
    Card(
          margin: const EdgeInsets.all(3),
          color: Colors.white,
          child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text('Thư mục này không có học phần', style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
                const Text('Thêm học phần vào thư mục này để sắp xếp chúng',
                  style: TextStyle(
                      fontSize: 12
                  ),),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/createStudySet",arguments: widget.folder);
                    },
                    child: const Text('Thêm học phần', style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),)
                )
              ]
          )
      ),
    ]
      )
    );
  }

  Widget _buildAlertDialog(BuildContext context){
    return AlertDialog(
    title:const Text('Xóa thư mục') ,
    content: const Text('Bạn chắc chắn muốn xóa vĩnh viễn thư mục này? Các học phần trong thư mục này sẽ không bị xóa mất'),
    actions: [
      TextButton(onPressed: ()=>{
        Navigator.pop(context),
      }, child: const Text('HỦY')
      ),
      TextButton(onPressed: () async=>{
        Navigator.pop(context),
        Navigator.pop(context),
        await folderDatabase.delete(widget.folder.id),
        await folderDatabaseRef.deleteFolder(widget.folder.id),
        Navigator.pop(context),
        Navigator.pop(context,'Delete Folder Successfully'),
      },
          child: const Text('XÓA')
      )
    ],
    );
  }

  Widget _buildDialogEdit(BuildContext context){
    return AlertDialog(
      title:const Text('Sửa thư mục') ,
      content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: widget.folder?.name??'',
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
                  initialValue: widget.folder?.name??'',
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
        }, child: const Text('Hủy')
        ),
        TextButton(onPressed: () async=>{
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save(),

            await folderDatabase.update(id: widget.folder.id??0, isDelete: false, name: nameFolder),

            await folderDatabaseRef.updateFolder(widget.folder.id, nameFolder, false),

            Navigator.pop(context),
            Navigator.pop(context,'Update Folder $nameFolder Successfully'),
            fetchFolder()


          }
        },
            child: const Text('Xác nhận')
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
