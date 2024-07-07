import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:finalapp/Service/Firebase/TopicDatabaseRef.dart';
import 'package:finalapp/Service/Firebase/UserVocabDatabaseRef.dart';
import 'package:finalapp/Service/Sqlite/TopicDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserVocabDatabase.dart';
import 'package:finalapp/dto/UserVocab.dart';
import 'package:finalapp/providers/counter_provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/UserDetail.dart';
import '../dto/Vocab.dart';

class LearningFlashCard extends StatefulWidget {
  var topic;
  LearningFlashCard({super.key,required this.topic});

  @override
  State<LearningFlashCard> createState() => _LearningFlashCardState();
}

class _LearningFlashCardState extends State<LearningFlashCard> {


  final SwipperController=SwiperController();

  Timer t = Timer(const Duration(seconds: 10), () {
  });

  FlutterTts flutterTts=FlutterTts();
  final vocabDatabase=VocabDatabase();

  final topicDatabase=TopicDatabase();
  
  final userVocabDatabase=UserVocabDatabase();

  late SharedPreferences prefs;
  

  var currentUser;


  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();
  
  UserVocabDatabaseRef userVocabDatabaseRef=UserVocabDatabaseRef();

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
    }
  }

  var listCount=0;

  var selectedIndex=0;

  var checkStudying='center';

  var checkKnowing=true;

  bool ignoreFirstDrag = true;

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

  var listVocab=[];

  Future<int?> getLength(int topicId)async{
    var x=!Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.getLength(topicId):await vocabDatabase.getLengthMarked(topicId);
    setState(() {
      listCount=x!;
    });
    return x;
  }


  late Timer timer;

  var mode=[];

  FlipCardController flipCardController=FlipCardController();


  void init(){
    getLength(widget.topic.id);
    fetchVocabs();
    Provider.of<CounterProvider>(context, listen: false).poValue=0;
    Provider.of<CounterProvider>(context, listen: false).neValue=0;
    Provider.of<CounterProvider>(context, listen: false).progressValue=0;
    Provider.of<CounterProvider>(context, listen: false).shuffle=false;
    Provider.of<CounterProvider>(context, listen: false).autoSpeak=false;
    Provider.of<CounterProvider>(context, listen: false).position=false;
    Provider.of<CounterProvider>(context, listen: false).autoSlide=false;
    flutterTts = FlutterTts();
    mode=[];
  }

  late Future<List<Vocab>?> futureVocabs;

  void fetchVocabs()async{
    Future<List<Vocab>?> _futureVocabs;
    var _listVocab=[];
    _futureVocabs =Provider.of<CounterProvider>(context, listen: false).shuffle
        ?!Provider.of<CounterProvider>(context, listen: false).modeStudy? vocabDatabase.fetchAllWithTopicRandom(widget.topic.id):vocabDatabase.fetchAllWithTopicShuffleMarked(widget.topic.id)
        :!Provider.of<CounterProvider>(context, listen: false).modeStudy?
    vocabDatabase.fetchAllWithTopic(widget.topic.id):vocabDatabase.fetchAllWithTopicWithMark(widget.topic.id,true);

    setState(() {
      futureVocabs=_futureVocabs;
      listVocab=_listVocab;
    });
    var dataVocab=await _futureVocabs;

    if(dataVocab!=null){
      for(var data in dataVocab){
        _listVocab.add(data);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    init();
    fetchVocabs();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon:const Icon(Icons.clear_outlined),onPressed: (){
          Navigator.pop(context);
        },),
        title: Text('${(Provider.of<CounterProvider>(context, listen: false).progressValue==listCount?Provider.of<CounterProvider>(context, listen: false).progressValue:Provider.of<CounterProvider>(context, listen: false).progressValue+1).toString()}/${listCount.toString()}',style: const TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        actions: [
          IconButton(icon:const Icon(Icons.settings),onPressed: (){
            showDialog(context: context, builder: (context)=>Dialog.fullscreen(
                child:_buildItemSetting(context)
            ));
          },),
        ],
      ),
      body:Column(
          children: [
            Container(
              child: LinearPercentIndicator(
                width: 360,
                lineHeight: 5.0,
                percent:listCount==0?0.1:((Provider.of<CounterProvider>(context, listen: false).progressValue+1)>listCount)?1:(Provider.of<CounterProvider>(context, listen: false).progressValue+1)/listCount,
                progressColor: Colors.blue,
              )
            ),
              Expanded(child:_buildItem(context)),
        ]
      )
    );
  }

  Widget _buildItem(BuildContext context){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.watch<CounterProvider>().neValue.toString(),style: const TextStyle(
                color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20
              ),),
              Text(context.watch<CounterProvider>().poValue.toString(),style: const TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20
              ))
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _buildCardList(context),
          Container(
            margin: const EdgeInsets.all(20),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child:Provider.of<CounterProvider>(context, listen: false).autoSlide?const Text('Chế độ tự động chuyển từ vựng',style: TextStyle(
                    color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                  ),):null,
                ),
                !Provider.of<CounterProvider>(context, listen: false).autoSlide?const SizedBox(
                  width: 200,
                ):Container(),
                IconButton(icon:Icon(!Provider.of<CounterProvider>(context, listen: false).autoSlide?Icons.next_plan:Icons.slideshow,),onPressed: (){
                  Provider.of<CounterProvider>(context, listen: false).changeAutoSlide();
                },)
              ],
            )
          )
        ],
      ),
    );
  }

  Widget _buildCardList(BuildContext context){
    return Container(
        width: 1000,
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
                  var vocabs=snapshot.data!;
                  if(Provider.of<CounterProvider>(context, listen: false).shuffle){
                    vocabs.shuffle(Random(42));
                  }
                  return Swiper(
                    autoplayDelay: 10000,
                    autoplay:Provider.of<CounterProvider>(context, listen: false).autoSlide?true:false ,
                    index: Provider.of<CounterProvider>(context, listen: false).progressValue ,
                    controller:SwipperController,
                    onIndexChanged:(index)async{
                      if(index<Provider.of<CounterProvider>(context, listen: false).progressValue){
                          if(mode.isNotEmpty&& index<mode.length&& mode[index]=='left'){
                            if(Provider.of<CounterProvider>(context, listen: false).neValue>0){
                              Provider.of<CounterProvider>(context, listen: false).decrementNeValue();
                            }
                          }
                          else if(mode.isNotEmpty&&index<mode.length&& mode[index]=='right'){
                            if(Provider.of<CounterProvider>(context, listen: false).poValue>0){
                              Provider.of<CounterProvider>(context, listen: false).decrementPoValue();
                            }
                          }
                          mode.removeLast();
                      }
                      else {
                        mode.add('right');
                        Provider.of<CounterProvider>(context, listen: false).incrementPoValue();
                        if(mode.length==listCount-1&&Provider.of<CounterProvider>(context, listen: false).autoSlide){
                          t = Timer(const Duration(seconds: 10), () async {
                            Provider.of<CounterProvider>(context, listen: false).incrementPoValue();
                            Provider.of<CounterProvider>(context, listen: false).changeProgress(listCount);
                            await topicDatabase.update(id: widget.topic.id,name: widget.topic.nameTopic,progress: Provider.of<CounterProvider>(context, listen: false).poValue);
                            await topicDatabaseRef.updateTopic(widget.topic.id, widget.topic.nameTopic, Provider.of<CounterProvider>(context, listen: false).poValue);
                            addUserVocab(mode);
                            final message=await Navigator.pushNamed(context, "/resultFlashCard",arguments: widget.topic);
                            if(message!=null){
                              init();
                            }
                          });
                        }
                        else{
                          t.cancel();
                        }
                      }
                      Provider.of<CounterProvider>(context, listen: false).autoSpeak?flutterTts.speak(vocabs[index].en.toString()):null;
                      Provider.of<CounterProvider>(context, listen: false).changeProgress(index);
                      },
                    loop: false,
                    itemBuilder: (BuildContext context, int index) {
                      return
                        Draggable(
                          onDragStarted: (){
                          },
                          axis: Axis.horizontal,
                          onDragUpdate: (drag){
                            Size screenSize = MediaQuery.of(context).size;
                            Offset centerPosition = Offset(screenSize.width / 2, screenSize.height / 2);
                            if (drag.globalPosition.dx <0&&drag.globalPosition.dx<centerPosition.dx) {
                                setState(() {
                                  checkStudying='left';
                                });
                            }
                            else if(drag.globalPosition.dx >0&&drag.globalPosition.dx>centerPosition.dx+200){
                             setState(() {
                               checkStudying='right';
                             });
                            }
                          },
                            onDragEnd: (drag) async {
                              Size screenSize = MediaQuery.of(context).size;
                              Offset centerPosition = Offset(screenSize.width / 2, screenSize.height / 2);
                              var check='left';
                                if (drag.offset.dx <0&&drag.offset.dx<centerPosition.dx) {
                                  if (Provider.of<CounterProvider>(context, listen: false).progressValue <= listCount) {
                                    Provider.of<CounterProvider>(context, listen: false).increaseProgress();
                                    Provider.of<CounterProvider>(context, listen: false).incrementNeValue();
                                  }
                                  mode.add('left');
                                  setState(() {
                                    checkStudying='left';
                                  });
                                }
                                else if(drag.offset.dx > 0 &&drag.offset.dx>centerPosition.dx-50){
                                  if (Provider.of<CounterProvider>(context, listen: false).progressValue <= listCount) {
                                    Provider.of<CounterProvider>(context, listen: false).increaseProgress();
                                  }
                                  check='right';
                                  mode.add('right');
                                  setState(() {
                                    checkStudying='right';
                                  });
                                }
                                SwipperController.next();
                                print(mode);
                                if(mode.length==listCount){
                                  check=='right'?mode.add('right'):check=='left'?mode.add('left'):null;
                                  check=='right'?Provider.of<CounterProvider>(context, listen: false).incrementPoValue():check=='left'?Provider.of<CounterProvider>(context, listen: false).incrementNeValue():null;
                                  await topicDatabase.update(id: widget.topic.id,name: widget.topic.nameTopic,progress: Provider.of<CounterProvider>(context, listen: false).poValue);
                                  await topicDatabaseRef.updateTopic(widget.topic.id, widget.topic.nameTopic, Provider.of<CounterProvider>(context, listen: false).poValue);
                                  addUserVocab(mode);
                                 final message=await Navigator.pushNamed(context, "/resultFlashCard",arguments: widget.topic);
                                 if(message!=null){
                                   init();
                                 }
                                }
                            },
                          data: vocabs[index],
                        feedback:
                        checkStudying=='right'?SizedBox(
                          width: 290,
                          height: 260,
                          child:Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(15.0)
                            ),
                            color: Colors.white,
                            child:
                            const Stack(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Center(child: Text('Biết', style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25
                                  ),
                                  )
                                  ),
                                  SizedBox(
                                    height: 60,
                                  ),
                                ]
                            ),
                          ),
                        ):checkStudying=='left'?SizedBox(
                          width: 290,
                          height: 260,
                          child:Card(
                            shape: RoundedRectangleBorder(
                               side: const BorderSide(color: Colors.orange, width: 2.0),
                              borderRadius: BorderRadius.circular(15.0)
                            ),
                            color: Colors.white,
                            child:
                            const Stack(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Center(child: Text('Đang học', style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25
                                  ),
                                  )
                                  ),
                                  SizedBox(
                                    height: 60,
                                  ),
                                ]
                            ),
                          ),
                        ):
                        SizedBox(
                          width: 290,
                          height: 260,
                        child:Card(
                          color: Colors.white,
                          child:
                          Stack(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Positioned(child: IconButton(
                                  icon: const Icon(Icons.headphones,), onPressed: () {
                                  flutterTts.speak(vocabs[index].en.toString());
                                },
                                )),
                                const SizedBox(
                                  height: 100,
                                ),
                                Center(child: Text(vocabs[index].en, style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                ),
                                )
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ]
                          ),
                        ),
                        ),
                        childWhenDragging: const Card(
                          color: Colors.white,
                        ),
                        child:FlipCard(
                          controller:flipCardController ,
                        fill: Fill.fillBack,
                        // Fill the back side of the card to make in the same size as the front.
                        direction: FlipDirection.HORIZONTAL,
                        // default
                        side: CardSide.FRONT,
                        // The side to initially display.
                        front:
                        Card(
                          color: Colors.white,
                          child:
                          Stack(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                               Positioned(child: IconButton(
                                 icon: const Icon(Icons.headphones,), onPressed: () {
                                 flutterTts.speak(vocabs[index].en.toString());
                               },
                               )),
                                const SizedBox(
                                  height: 100,
                                ),
                                Center(child: Text(!Provider.of<CounterProvider>(context, listen: false).position?vocabs[index].en:vocabs[index].vi, style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                ),
                                )
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ]
                          ),
                        ),
                        back: Card(
                          color: Colors.white,
                          child:
                          Stack(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Positioned(child: IconButton(
                                  icon: const Icon(Icons.headphones,), onPressed: () {
                                    flutterTts.speak(vocabs[index].vi.toString());
                                },
                                )),
                                const SizedBox(
                                  height: 100,
                                ),
                                Center(child: Text(!Provider.of<CounterProvider>(context, listen: false).position?vocabs[index].vi:vocabs[index].en, style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                ),
                                )
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ]
                          ),
                        ),
                        // autoFlipDuration: Duration(seconds: 2)
                      )
                        );
                    },
                    itemCount: vocabs.length,
                    viewportFraction: 0.9,
                    scale: 0.9,
                    // pagination:const SwiperPagination(
                    //     builder: DotSwiperPaginationBuilder(
                    //       size: 2,
                    //       activeColor: Colors.blue,
                    //       color: Colors.black,
                    //     )
                    // ),
                    control:!Provider.of<CounterProvider>(context, listen: false).autoSlide?const SwiperControl(
                        disableColor: Colors.grey,
                        color: Colors.black
                    ):null,
                  );
                }
              }
            }
        )
    );
  }

  Widget _buildItemSetting(BuildContext context){
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child:Text('Tùy chọn',style: TextStyle(
            color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold
          ),)),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: Material(
                      color:context.watch<CounterProvider>().shuffle?Colors.blue:Colors.white,
                      child: InkWell(
                        // Splash color
                        onTap: () {
                          context.read<CounterProvider>().changeShuffle();
                        },
                        child: const SizedBox(width: 56, height: 56, child: Icon(Icons.shuffle)),
                      ),
                    ),
                  ),
                  const Text('Trộn thẻ',style: TextStyle(
                    color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15
                  ),)
                ],
              ),
              Column(
                children: [
                  ClipOval(
                    child: Material(
                      color: context.watch<CounterProvider>().autoSpeak?Colors.blue:Colors.white,
                      child: InkWell(
                         // Splash color
                        onTap: () {
                          context.read<CounterProvider>().changeAutoSpeak();
                        },
                        child: const SizedBox(width: 56, height: 56, child: Icon(Icons.headset_outlined)),
                      ),
                    ),
                  ),
                const Text('Phát bản thu',style: TextStyle(
                    color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15
                ),)
              ]
              ),
              Column(
                  children: [
                    ClipOval(
                      child: Material(
                        color: context.watch<CounterProvider>().position?Colors.blue:Colors.white,
                        child: InkWell(
                          // Splash color
                          onTap: () {
                            context.read<CounterProvider>().changePosition();
                          },
                          child: const SizedBox(width: 56, height: 56, child: Icon(Icons.settings_input_composite)),
                        ),
                      ),
                    ),
                    const Text('Đổi vị trí',style: TextStyle(
                        color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15
                    ),)
                  ]
              ),
            ],
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


  void addUserVocab(mode)async{
    for(int i=0;i<mode.length;i++){
      var dataUserLearn=await userVocabDatabase.fetchByUserIdAndVocabId(currentUser.id, listVocab[i].id);
      if(dataUserLearn!=null) {
        if(dataUserLearn.numStudy>0&& dataUserLearn.valueTrue>=5) {
          dataUserLearn.statusStudy = "Đã thành thạo";
        }
        else if(dataUserLearn.numStudy > 0){
          dataUserLearn.statusStudy = "Đang học";

        }
        updateStatusVocab(currentUser.id, listVocab[i].id, mode[i]=='right'?dataUserLearn.valueTrue+1:dataUserLearn.valueTrue, dataUserLearn.statusStudy, dataUserLearn.numStudy+1);
      }
      else{
        updateStatusVocab(currentUser.id,listVocab[i].id,mode[i]=='right'?1:0,"Đang học",1);
      }

    }
  }

  void updateStatusVocab(int userId, int vocabId,int valueTrue, String status,int numStudy)async{
    await userVocabDatabase.deleteByUserIdAndVocabId(userId,vocabId);
    await userVocabDatabaseRef.deleteUserVocab(userId, vocabId);
    var data=await userVocabDatabase.create(statusStudy: status, vocabId: vocabId, userId: userId, numStudy: numStudy, valueTrue:valueTrue);
    data ??= await userVocabDatabase.create(statusStudy: status, vocabId: vocabId, userId: userId, numStudy: numStudy, valueTrue: valueTrue);
    await userVocabDatabaseRef.addUserVocab(UserVocab(id: data??0, statusStudy: status, vocabId: vocabId, userId: userId, numStudy: numStudy, valueTrue: valueTrue));
  }


}
