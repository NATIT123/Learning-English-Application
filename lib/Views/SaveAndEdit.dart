import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finalapp/Service/Firebase/TopicDatabaseRef.dart';
import 'package:finalapp/Service/Firebase/VocabDatabaseRef.dart';
import 'package:finalapp/Views/SettingTopic.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/UserVocabDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';
import '../dto/Vocab.dart';
class SaveAndEdit extends StatefulWidget {
  var topic;
  SaveAndEdit({super.key,required this.topic});

  @override
  State<SaveAndEdit> createState() => _SaveEditTopicState();
}

class _SaveEditTopicState extends State<SaveAndEdit> {

  final  _formKeyTopic=GlobalKey<FormState>();

  var isPublic;


  var headTitle='';

  var itemCount=2;

  var buttonDescription=false;

  final topicDatabase=TopicDatabase();

  final vocabDatabase=VocabDatabase();

  final userVocabDatabase=UserVocabDatabase();

  final userDatabase=UserDatabase();

  final controlAdd=ScrollController();

  final controlEdit=ScrollController();

  VocabDatabaseRef vocabDatabaseRef=VocabDatabaseRef();

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

  var title='';

  var listEn=[];

  var listVi=[];

  late Future<List<Topic>?> futureTopics;

  late Future<List<Vocab>?> futureVocabs;

  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();


  String? filePath;


  final date='${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}'
      ' ${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}:${DateTime.now().second.toString().padLeft(2,'0')}  ';


  void _pickFile(context) async {
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
      print(listEn);
    }
  }
  List<FocusNode> _focusNodes=List.generate(2, (index) => FocusNode());

  double offset=0.0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchVocabs();
  }


  void _scrollToEnd(context){
    widget.topic==null? controlAdd.animateTo(controlAdd.position.maxScrollExtent+200,curve: Curves.easeInOut, duration: const Duration(seconds: 1)).then((value) =>FocusScope.of(context).requestFocus(_focusNodes.last)):controlEdit.animateTo(controlEdit.position.maxScrollExtent,curve: Curves.easeInOut, duration: const Duration(seconds: 1)).then((value) =>FocusScope.of(context).requestFocus(_focusNodes.last));
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          _scrollToEnd(context);
        },
        child: const Icon(Icons.add,size: 30,color: Colors.white,),
      ),
      appBar: AppBar(
        title: const Text('Sửa và lưu học phần',style: TextStyle(
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
                    var createdEntry = await topicDatabase.create(name: title,
                        isPublic: isPublic == 'Mọi người' ? true : false,progress: 0,
                        createdAt: date, userId:currentUser.id);
                   createdEntry??await topicDatabase.create(name: title,
                       isPublic: isPublic == 'Mọi người' ? true : false,progress: 0,
                       createdAt: date, userId:currentUser.id);
                   await topicDatabaseRef.addTopic(Topic(nameTopic: title,
                       isPublic: isPublic == 'Mọi người' ? true : false,progress: 0,
                       createdAt: date, userId:currentUser.id, id: createdEntry??0));
                   print('Length:${listVi}');
                    for (var i = 0; i < listVi.length; i++) {
                      final result = await vocabDatabase.create(en: listEn[i],
                          vi: listVi[i],
                          topicId: createdEntry ?? 0, isMark: false, countStudy: 0);
                      result??await vocabDatabase.create(en: listEn[i],
                          vi: listVi[i],
                          topicId: createdEntry ?? 0, isMark: false, countStudy: 0);
                      await vocabDatabaseRef.addVocab(Vocab(en: listEn[i],
                          vi: listVi[i],
                          topicId: createdEntry ?? 0, isMark: false, countStudy: 0, id: result??0));
                    }
                    Navigator.pop(context, 'Add Topic $title Successfully');
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
              initialValue: widget.topic.nameTopic,
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
                        _pickFile(context);
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
            _buildListViewEdit(context)
          ],
        )
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
