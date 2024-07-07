import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:finalapp/Service/Sqlite/UserVocabDatabase.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Service/Firebase/TopicDatabaseRef.dart';
import '../Service/Firebase/VocabDatabaseRef.dart';
import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/UserDetail.dart';
import '../dto/Vocab.dart';
import '../providers/counter_provider.dart';
import 'CreateTopic.dart';
class DetailTopic extends StatefulWidget {
  var topic;
  DetailTopic({super.key,required this.topic});

  @override
  State<DetailTopic> createState() => _DetailTopicState();
}

class _DetailTopicState extends State<DetailTopic> {

  FlutterTts flutterTts=FlutterTts();

  
  var name;

  late UserDetail currentUser;

  final vocabDatabase=VocabDatabase();
  final topicDatabase=TopicDatabase();
  final userDatabase=UserDatabase();

  final userVocabDatabase=UserVocabDatabase();

  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();

  VocabDatabaseRef vocabDatabaseRef=VocabDatabaseRef();

  late Future<List<Vocab>?> futureVocabs;

  var modeStudy=false;

  var listCount=0;

  var userData;

  var checkModeStudy=false;

  var row=0;

  var message='';
  late SharedPreferences prefs;
  


  Future<int?> getLength(int topicId)async{
    var x= await vocabDatabase.getLength(topicId);
    setState(() {
      listCount=x!;
    });
  }

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

  void checkMode()async{
    int? rowCount=await vocabDatabase.getLengthMarked(widget.topic.id);
    setState(() {
      if(rowCount==0){
        modeStudy=false;
        Provider.of<CounterProvider>(context, listen: false).modeStudy=false;
      }
      else {
        row=rowCount!;
        modeStudy=true;
        Provider.of<CounterProvider>(context, listen: false).modeStudy=true;
      }
    });
  }

  late Future<List<Vocab>?> futureVocabMarked;
  var listVocabStatus=[];


  void fetchUsers()async{
    print(widget.topic.id);
    var dataUser=await userDatabase.fetchById(widget.topic.userId);
    var list=await userDatabase.fetchAll();
    setState(() {
      userData=dataUser;
    });
  }
  void fetchVocabs() async{
    var _listVocabStatus=[];
    var dataMarked=vocabDatabase.fetchAllWithTopicWithMark(widget.topic.id,true);
    var data=vocabDatabase.fetchAllWithTopic((widget.topic.id));
    setState(() {
      futureVocabs=data;
      futureVocabMarked=dataMarked;
    });
    var dataVocab=await data;
    if(dataVocab!=null){
      if(dataVocab.isNotEmpty) {
        for (var data in dataVocab) {
          var dataUserVocab = await userVocabDatabase.fetchByUserIdAndVocabId(
              currentUser.id,data.id);
          if(dataUserVocab!=null){
            _listVocabStatus.add(dataUserVocab?.statusStudy);
          }
        }
      }
    }
    setState(() {
      listVocabStatus=_listVocabStatus;
    });
  }

  var initStyle=const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15
  );

  Future<void>speak(String text) async{
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    flutterTts.setLanguage("en-US");
    name=widget.topic.nameTopic;
    fetchUsers();
    fetchVocabs();
    getLength(widget.topic.id);
    checkMode();
    Provider.of<CounterProvider>(context, listen: false).modeStudy=false;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
            IconButton(onPressed: (){
              showDialog(context: context, builder: (context)=>Dialog.fullscreen(
                  child:_buildItemMore(context)
              ));
            }, icon: const Icon(Icons.more_vert,size: 20,))
        ],
      ),
        body:SingleChildScrollView(
          child:Container(
        padding: const EdgeInsets.all(10),
      child:
      Column(
      children: [
        Column(
        mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
        _buildCardList(context),
        Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('dsdsd',style: initStyle,),
              Row(
                children: [
                  userData!=null?convertImage(userData.imgPath.toString()):const Text(''),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(userData?.userName??'',style: const TextStyle(
                    color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                  ),),
                  const SizedBox(
                    width: 20,
                  ),
                  Text('${listCount.toString()} thuật ngũ',style: const TextStyle(
                    color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                  ),)
                ],
              )
            ],
          )
        ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: ()async{
                final message=await Navigator.pushNamed(context, "/learningFlashCard",arguments: widget.topic);
                if(message!=null){
                  fetchVocabs();
                  getLength(widget.topic.id);
                  checkMode();
                  Provider.of<CounterProvider>(context, listen: false).modeStudy=false;
                }
              },
              child:Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.flash_auto,color: Colors.blue,),
                title: Text('Học FlashCard',style: initStyle
                ),),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: ()async{
                final message=await Navigator.pushNamed(context, "/multipleChoice",arguments: widget.topic);
                if(message!=null){
                  fetchVocabs();
                  getLength(widget.topic.id);
                  checkMode();
                  Provider.of<CounterProvider>(context, listen: false).modeStudy=false;
                }
              },
            child:Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.flash_auto,color: Colors.blue,),
                title: Text('Thi trắc nghiệm',style: initStyle
                ),
                trailing: TextButton(onPressed: (){
                  Navigator.pushNamed(context, "/leaderBoard",arguments: [widget.topic.id,"multipleChoice"]);
                }, child:const Text('Bảng xếp hạng',style: TextStyle(
                    color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                ),
                )
                ),
              ),

            ),
            ),
            InkWell(
              onTap: ()async{
                final message=await Navigator.pushNamed(context, "/typeWord",arguments: widget.topic);
                if(message!=null){
                  fetchVocabs();
                  getLength(widget.topic.id);
                  checkMode();
                  Provider.of<CounterProvider>(context, listen: false).modeStudy=false;
                }
              },
            child:Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.flash_auto,color: Colors.blue,),
                title: Text('Thi gõ từ',style: initStyle
                ),
              trailing: TextButton(onPressed: (){
                Navigator.pushNamed(context, "/leaderBoard",arguments: [widget.topic.id,"typeWord"]);
              }, child:const Text('Bảng xếp hạng',style: TextStyle(
                color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
              ),
              )
              ),
              ),
            ),
            ),
            Text('Thẻ',style: initStyle,),
           modeStudy?Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                  child:ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      backgroundColor:!Provider.of<CounterProvider>(context, listen: false).modeStudy?Colors.blue:Colors.white
                    ),
                    onPressed: () {
                      setState(() {
                        Provider.of<CounterProvider>(context, listen: false).changeModeStudy();
                      });
                    },
                    child: const Text('Học hết',style: TextStyle(
                      color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                    ),),
                  ),
                  ),
                  SizedBox(
                    width: 160,
                  child:Container(
                    child:ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          side: const BorderSide(
                            color: Colors.black,
                          ),
                          backgroundColor: Provider.of<CounterProvider>(context, listen: false).modeStudy?Colors.blue:Colors.white
                      ),
                    onPressed: () {
                      setState(() {
                        Provider.of<CounterProvider>(context, listen: false).changeModeStudy();
                      });
                    },
                    child: Text('Học ${row.toString()}',style: const TextStyle(
                        color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                    ),),
                    )
        )
                  )
                ],
              ),
            ):Container()
          ]
         ),
        _buildItem(context)
              ]

      )
          )

      )
    );
  }

  Widget _buildItem(BuildContext context){
    return SizedBox(
        height: 500,
        child:
        FutureBuilder<List<Vocab>?>(
            future:Provider.of<CounterProvider>(context, listen: false).modeStudy?futureVocabMarked:futureVocabs,
            builder: (context,snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              else {
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No vocabs...', style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  );
                }
                else {
                  final vocabs=snapshot.data!;
                  return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          Card(
                              color: Colors.white,
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      ListTile(
                                        leading: Text(vocabs[index].en,style: const TextStyle(
                                          fontSize: 15
                                        ),),
                                        trailing:
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [Row(
                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [


                                                    IconButton(onPressed: () {
                                                      flutterTts.speak(vocabs[index].en.toString());
                                                    },
                                                        icon: const Icon(Icons.headphones)),
                                                    IconButton(onPressed: () async{
                                                      await vocabDatabase.update(id: vocabs[index].id,
                                                          en:vocabs[index].en,
                                                          vi:vocabs[index].vi,
                                                          isMark:!vocabs[index].isMark
                                                      );
                                                      await vocabDatabaseRef.updateVocab(vocabs[index].id,vocabs[index].en,vocabs[index].vi,!vocabs[index].isMark);
                                                      fetchVocabs();
                                                      checkMode();
                                                    },
                                                        icon:!vocabs[index].isMark?const Icon(Icons.star_border):const Icon(Icons.star)),
                                                  ]
                                              ),
                                                // Text(index<listVocabStatus.length&&listVocabStatus.isNotEmpty?listVocabStatus[index].toString():'Chưa học',style: const TextStyle(
                                                //   fontWeight:FontWeight.bold,fontSize: 1
                                                // ),)
                                              ],
                                            )
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 15),
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(vocabs[index].vi,style: const TextStyle(
                                                fontSize: 20
                                            ),),
                                            Text(index<listVocabStatus.length&&listVocabStatus.isNotEmpty?listVocabStatus[index].toString():'Chưa học',style: const TextStyle(
                                              fontWeight:FontWeight.bold,fontSize: 15
                                            ),)
                                          ],
                                        )
                                      )
                                    ],
                                  )
                              )

                          ), separatorBuilder: (context, index) =>
                  const SizedBox(
                    height: 10,
                  ), itemCount: vocabs.length);
                }
              }
            }
      )
              );
  }

  Widget _buildCardList(BuildContext context){
    return Container(
      width: 700,
      height: 300,
      // margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<List<Vocab>?>(
        future:futureVocabs,
        builder: (context,snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No Vocabs...', style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                ),
              );
            }
            else {
              final vocabs=snapshot.data!;
              return Swiper(
                autoplayDisableOnInteraction: true,
                loop: false,
                autoplay: true,
                itemBuilder: (BuildContext context, int index) {
                  return FlipCard(
                    fill: Fill.fillBack,
                    // Fill the back side of the card to make in the same size as the front.
                    direction: FlipDirection.VERTICAL,
                    // default
                    side: CardSide.FRONT,
                    // The side to initially display.
                    front:
                    Card(
                      color: Colors.white,
                      child:
                      Column(
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            Center(child: Text(vocabs[index].en, style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,

                            ),
                            )
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.zoom_in_map),
                                onPressed: ()async {
                                  Navigator.pushNamed(context, "/learningFlashCard",arguments: widget.topic);
                                },),
                            )
                          ]
                      ),
                    ),
                    back: Card(
                      color: Colors.white,
                      child:
                      Column(
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            Center(child: Text(vocabs[index].vi, style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25
                            ),
                            )
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: const Icon(Icons.zoom_in_map),
                                onPressed: () {
                                  return;
                                },),
                            )
                          ]
                      ),
                    ),
                    // autoFlipDuration: Duration(seconds: 2)
                  );
                },
                itemCount: vocabs.length,
                viewportFraction: 0.8,
                scale: 0.9,
                pagination: const SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      size: 5,
                      activeColor: Colors.blue,
                      color: Colors.black,
                    )
                ),
                control: const SwiperControl(
                    disableColor: Colors.grey,
                    color: Colors.black
                ),
              );
            }
          }
        }
    )
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
            onTap: ()async{
              final message=await Navigator.pushNamed(context, "/addTopicFolder",arguments: widget.topic);
              if(message!=null){
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
            child:Row(
              children: [
                const Icon(Icons.folder),
                const SizedBox(
                  width: 40,
                ),
                Text('Thêm vào thư mục',style: initStyle,)
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: ()async{
              var dataVocab=Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.fetchAllWithTopicWithMark(widget.topic.id,true):await vocabDatabase.fetchAllWithTopic(widget.topic.id);
              if(dataVocab!=null&&dataVocab.isNotEmpty) {
                exportCsv(dataVocab);
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content:
                const Center(child:Text('Xuất File CSV thành công',)),
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
            child:Row(
              children: [
                const Icon(Icons.file_copy_rounded),
                const SizedBox(
                  width: 40,
                ),
                Text('Xuất File CSV',style: initStyle)
              ],
            ),
          ),
          currentUser.id!=widget.topic.userId?const SizedBox(
            height: 20,
          ):Container(),
          currentUser.id!=widget.topic.userId?InkWell(
            onTap: (){
              Navigator.pushNamed(context, "/saveAndEdit",arguments:widget.topic);
            },
            child:Row(
              children: [
                const Icon(Icons.save),
                const SizedBox(
                  width: 40,
                ),
                Text('Lưu và chỉnh sửa',style: initStyle)
              ],
            ),
          ):Container(),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTopic(topic: widget.topic,)));
            },
          child:Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(
                width: 40,
              ),
              Text('Sửa',style:initStyle)
            ],
          ),
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
                Text('Xóa học phần',style: initStyle)
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
              child: Text('Hủy',style: initStyle,),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlertDialog(BuildContext context){
    return AlertDialog(
      title:const Text('Xóa chủ đề') ,
      content: const Text('Bạn chắc chắn muốn xóa học phần này vĩnh viễn?'),
      actions: [
        TextButton(onPressed: ()=>{
          Navigator.pop(context),
        }, child: const Text('HỦY',style: TextStyle(
          color: Colors.black
        ),)
        ),
        TextButton(onPressed: () async=>{
          await topicDatabase.delete(widget.topic.id),
          await vocabDatabase.deleteVocab(widget.topic.id),
          await topicDatabaseRef.deleteTopic(widget.topic.id),
          await vocabDatabaseRef.deleteVocabByTopicId(widget.topic.id),
          Navigator.pop(context),
          Navigator.pop(context),
          Navigator.pop(context,'Delete Topic $name Successfully'),
        },
            child: const Text('XÓA',style: TextStyle(
    color: Colors.black
    ),)
        )
      ],
    );
  }

  void exportCsv(dataTopic)async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    List<List<dynamic>> rows = [];
    List<dynamic> row = [];
    row.add("En");
    row.add("Vi");
    rows.add(row);
    for(var data in dataTopic){
      List<dynamic> row = [];
      row.add(data.en);
      row.add(data.vi);
      rows.add(row);
    }
    String csv = const ListToCsvConverter().convert(rows);

    String dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String file = "$dir";

    File f = File("$file/${widget.topic.nameTopic}.csv");

    f.writeAsString(csv);
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

