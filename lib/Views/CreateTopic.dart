import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finalapp/Service/Firebase/VocabDatabaseRef.dart';
import 'package:finalapp/Views/SettingTopic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/Firebase/TopicDatabaseRef.dart';
import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/UserVocabDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';
import '../dto/Vocab.dart';
class CreateTopic extends StatefulWidget {
  var topic;
  CreateTopic({super.key,required this.topic});

  @override
  State<CreateTopic> createState() => _CreateTopicState();
}

class _CreateTopicState extends State<CreateTopic> {

  final  _formKeyTopic=GlobalKey<FormState>();

  var isPublic;


  var headTitle='';

  var itemCount=3;

  var buttonDescription=false;

  VocabDatabaseRef vocabDatabaseRef = VocabDatabaseRef();
  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();


  final topicDatabase=TopicDatabase();

  final vocabDatabase=VocabDatabase();

  final userVocabDatabase=UserVocabDatabase();

  final userDatabase=UserDatabase();

  final controlAdd=ScrollController();

  final controlEdit=ScrollController();


  var title='';

  var listEn=[];

  var listVi=[];

  late Future<List<Topic>?> futureTopics;

  late Future<List<Vocab>?> futureVocabs;


  String? filePath;


  final date='${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}'
      ' ${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}:${DateTime.now().second.toString().padLeft(2,'0')}  ';


  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    filePath = result.files.first.path!;
    var input;
    var _listEn=[];
    var _listVi=[];
    try {
      input = File(filePath!).openRead();
      final fields = await input.transform(utf8.decoder).transform(
          const CsvToListConverter()).toList();
      _listEn.clear();
      _listVi.clear();
      _listEn.addAll(fields.skip(1).map((data) => data[0].toString()).toList());
      print(_listEn);
      _listVi.addAll(fields.skip(1).map((data) => data[1].toString()).toList());
      setState(() {
        listVi=_listVi;
        listEn=_listEn;
        itemCount = fields.length +1;
        _focusNodes=List.generate(itemCount, (index) => FocusNode());
      });
      FilePickerStatus.done;
    } finally {
      if (input != null) {
        FilePickerStatus.done;
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content:
          const Center(child:Text('Nhập File CSV thành công',)),
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
  }

  late SharedPreferences prefs;

  var currentUser;

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
    }
  }



  void fetchVocabs()async{
    if(widget.topic!=null) {
      var data=vocabDatabase.fetchAllWithTopic(widget.topic.id);
      setState(() {
        futureVocabs=data;
      });
      var _itemCount=0;
      var _listVi=[];
      var _listEn=[];
      try {
        var dataVocab = await data;
        if(dataVocab!=null){
          _itemCount=dataVocab.length;
          for(var vocab in dataVocab){
            _listVi.add(vocab.vi);
            _listEn.add(vocab.en);
          }
        }
      }catch(err){
        print(err);
      }
      setState(() {
        listVi=_listVi;
        listEn=_listEn;
        itemCount=_itemCount;
        _focusNodes=List.generate(itemCount, (index) => FocusNode());
      });
    }
  }
  List<FocusNode> _focusNodes=List.generate(3, (index) => FocusNode());

  double offset=0.0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchVocabs();
  }


  void _scrollToEnd(){
    widget.topic==null? controlAdd.animateTo(controlAdd.position.maxScrollExtent+200,curve: Curves.easeInOut, duration: const Duration(seconds: 1)).then((value) =>FocusScope.of(context).requestFocus(_focusNodes.last)):controlEdit.animateTo(controlEdit.position.maxScrollExtent,curve: Curves.easeInOut, duration: const Duration(seconds: 1)).then((value) =>FocusScope.of(context).requestFocus(_focusNodes.last));
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controlAdd.removeListener(_scrollToEnd);
    controlAdd.dispose();
    controlEdit.removeListener(_scrollToEnd);
    controlEdit.dispose();
    for(var focusNode in _focusNodes){
      focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            itemCount=itemCount+1;
            _focusNodes.add(FocusNode());
          });
          _scrollToEnd();
        },
        child: const Icon(Icons.add,size: 30,color: Colors.white,),
      ),
      appBar: AppBar(
        title: Text(widget.topic==null?'Tạo học phần':'Sửa học phần',style: const TextStyle(
          color:Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w400
        ),),
        actions:  [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.topic==null?IconButton(icon:const Icon(Icons.settings),onPressed: ()async{
               final result= await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingTopic()),
                );
               if(result!=null){
                 isPublic=result;
               }
              },):Container(),
              const SizedBox(
                width: 10,
              ),
              IconButton(icon:const Icon(Icons.check),onPressed: ()async{
                if (_formKeyTopic.currentState!.validate()) {
                  _formKeyTopic.currentState?.save();
                  if (widget.topic == null) {
                    var createdEntry = await topicDatabase.create(name: title,
                        isPublic: isPublic == 'Mọi người' ? true : false,progress: 0,
                        createdAt: date, userId:currentUser.id);

                    if(createdEntry!=null){
                      await topicDatabaseRef.addTopic(Topic(nameTopic: title,id:createdEntry,
                          isPublic: isPublic == 'Mọi người' ? true : false,progress: 0,
                          createdAt: date, userId:currentUser.id));
                    }
                    for (var i = 0; i < listEn.length; i++) {
                      final result = await vocabDatabase.create(en: listEn[i],
                          vi: listVi[i],
                          topicId: createdEntry ?? 0, isMark: false, countStudy: 0);
                      if(result!=null){
                        await vocabDatabaseRef.addVocab(Vocab(en: listEn[i],
                            vi: listVi[i],
                            topicId: createdEntry ?? 0, isMark: false, countStudy: 0,id:result));
                      }
                    }
                    Navigator.pop(context, 'Add Topic $title Successfully');
                  }
                  else{
                    try {
                      var dataVocab = await futureVocabs;
                      if(dataVocab!=null){
                        for(var vocab in dataVocab){
                          await vocabDatabase.delete(vocab.id);
                          await vocabDatabaseRef.deleteVocab(vocab.id);
                        }
                      }
                    }catch(err){
                      if (kDebugMode) {
                        print(err);
                      }
                    }
                      var data=await topicDatabase.update(id: widget.topic.id,name:title,progress: 0);
                      await topicDatabaseRef.updateTopic(widget.topic.id,title,0);
                      for (var i = 0; i < itemCount; i++) {
                        final result = await vocabDatabase.create(en: listEn[i],
                            vi: listVi[i],
                            topicId: widget.topic.id ?? 0, isMark: false, countStudy: 0);
                        if(result!=null){
                          vocabDatabaseRef.addVocab(Vocab(en: listEn[i],
                              vi: listVi[i],
                              topicId: widget.topic.id ?? 0, isMark: false, countStudy: 0, id: result)) ;
                        }
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context,'Update Topic $title Successfully');
                  }
                }
              },),
            ],
          )
        ],
      ),
      body:SingleChildScrollView(
      child:Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
            height: 500,
            child:_buildFormAdd(context),
            )
          ],
        ),
      )
      ),
      );
  }

  Widget _buildFormAdd(BuildContext context){
    return Form(
        key: _formKeyTopic,
        child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          autofocus: true,
          initialValue: widget.topic!=null?widget.topic.nameTopic:'',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:'Chủ đề, chương, đơn vị',
          ),
          validator: (String ?value){
            if(value==null||value.isEmpty){
              return 'Vui lòng nhập tên chủ đề';
            }
            return null;
          },
          onSaved: (String ?value){
            title=value??'';
          },
        ),

        const SizedBox(
          height: 10,
        ),

        const SizedBox(
          height: 50,
          child:Text('TIÊU ĐỀ',style: TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold,
            fontSize: 12
          ),),
        ),
        buttonDescription?Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                TextFormField(
                  autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText:'Học phần của bạn có chủ đề gì',
        ),
        validator: (String ?value){
          if(value==null||value.isEmpty){
            return 'Vui lòng nhập học phần chủ đề';
          }
          return null;
        },
                ),
          const SizedBox(
            height: 10,
          ),

          const SizedBox(
        height: 40,
        child:Text('MÔ TẢ',style: TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold,
            fontSize: 12
        ),
        ),
                ),
                ]
            ):Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           Row(
                mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon:const Icon(Icons.qr_code,color: Colors.blue,),onPressed: ()async{
                  _pickFile();
                },),
                const Text('Quét tài liệu',style: TextStyle(
                  color: Colors.blue,fontWeight: FontWeight.bold
                ),),

                ]
            ),
            !buttonDescription?Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 15,
                  color: Colors.blue,
                  icon:const Icon(Icons.add),onPressed: (){
                  setState(() {
                    buttonDescription=!buttonDescription;
                  });
                },),
                const Text('Mô tả',style: TextStyle(
                  color: Colors.blue,fontWeight: FontWeight.bold
                ),)
              ],
            ):Container()
          ],
        ),
        widget.topic==null? _buildListViewAdd(context):_buildListViewEdit(context)
      ],
    )
    );
  }

  Widget _buildListViewAdd(BuildContext context){
    return
    Expanded(
      child:ListView.builder(
        controller: controlAdd,
          shrinkWrap: true,
          itemBuilder:(context,index)=> Card(
        elevation: 10,
        child:
        Stack(
        children: [
          Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      if (index >= listEn.length) {
                        listEn.add(value);
                      } else {
                        listEn[index] = value;
                      }
                    },
                    focusNode: _focusNodes[index],
                    initialValue:index<listEn.length?listEn[index]:'',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:'Thuật ngữ',
                    ),
                    validator: (String ?value){
                      if(value==null||value.isEmpty){
                        return 'Vui lòng nhập thuật ngữ';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    onChanged: (value) {
                      // Cập nhật giá trị vào danh sách listVi
                      if (index >= listVi.length) {
                        listVi.add(value);
                      } else {
                        listVi[index] = value;
                      }
                    },
                    initialValue:index<listVi.length?listVi[index]:'',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:'Định nghĩa',
                    ),
                    validator: (String ?value){
                      if(value==null||value.isEmpty){
                        return 'Vui lòng nhập định nghĩa';
                      }
                      return null;
                    },
                  ),
                ],
              )
        ),
          Positioned(left: 275,bottom: 153,child: IconButton(icon:const Icon(Icons.close),
            color: Colors.grey, onPressed: () {
                if (itemCount > 1) {
                  if (index < listVi.length) {
                    listVi.removeAt(index);
                  }
                  if (index < listEn.length) {
                    listEn.removeAt(index);
                  }
                  setState(() {
                    itemCount = itemCount - 1;
                  });
                  _focusNodes.removeAt(index);
                }
              }
            )
            ,),
          ]
        )
    )

    ,itemCount:itemCount)
    );
  }

  Widget _buildListViewEdit(BuildContext context){
    return
      Expanded(
        child:FutureBuilder<List<Vocab>?>(
          future: vocabDatabase.fetchAllWithTopic(widget.topic.id),
          builder: (BuildContext context, AsyncSnapshot<List<Vocab>?> snapshot) {
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
            return ListView.builder(
                controller: controlEdit,
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    Card(
                        elevation: 10,
                        child:
                        Stack(
                          children: [
                        Container(
                            padding: const EdgeInsets.all(20),
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  onChanged: (value) {
                                    if (index >= listVi.length) {
                                      listVi.add(value);
                                    } else {
                                      listVi[index] = value;
                                    }
                                  },
                                  focusNode: _focusNodes[index],
                                  initialValue: listVi.length > index ? listVi[index] : null,
                                  autovalidateMode: AutovalidateMode
                                      .onUserInteraction,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Thuật ngữ',
                                  ),
                                  validator: (String ?value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập thuật ngữ';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                TextFormField(
                                  onChanged: (value) {
                                    if (index >= listEn.length) {
                                      listEn.add(value);
                                    } else {
                                      listEn[index] = value;
                                    }
                                  },
                                  initialValue: listEn.length > index ? listEn[index] : null,
                                  autovalidateMode: AutovalidateMode
                                      .onUserInteraction,
                                  decoration: const InputDecoration(
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black
                                      )
                                    ),
                                    enabledBorder:OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black
                                        )
                                    ),
                                    disabledBorder:OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black
                                        )
                                    ),

                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black
                                      )
                                    ),
                                    hintText: 'Định nghĩa',
                                  ),
                                  validator: (String ?value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui long nhap dinh nghia';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                        ),
                            Positioned(left: 275,bottom: 153,child: IconButton(icon:const Icon(Icons.close),
                              color: Colors.grey, onPressed: () {
                                  if (itemCount > 1) {
                                    if (index < listVi.length) {
                                      listVi.removeAt(index);
                                    }
                                    if (index < listEn.length) {
                                      listEn.removeAt(index);
                                    }
                                    setState(() {
                                      itemCount = itemCount - 1;
                                    });
                                    _focusNodes.removeAt(index);
                                  }
                                }

    )
                              ,),
                ]
                        )
                )


                , itemCount: itemCount);
          }

            }
  }
        )


      );
  }

}
