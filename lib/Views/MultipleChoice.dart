import 'dart:convert';
import 'dart:math';

import 'package:finalapp/Service/Firebase/HistoryDatabaseRef.dart';
import 'package:finalapp/Service/Sqlite/HistoryDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserVocabDatabase.dart';
import 'package:finalapp/Service/Sqlite/VocabDatabase.dart';
import 'package:finalapp/providers/multiple_choice.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Firebase/TopicDatabaseRef.dart';
import '../Service/Firebase/UserVocabDatabaseRef.dart';
import '../dto/History.dart';
import '../dto/UserDetail.dart';
import '../dto/UserVocab.dart';
import '../dto/Vocab.dart';
import '../providers/counter_provider.dart';

class MultipleChoice extends StatefulWidget {
  var topic;
  MultipleChoice({super.key,required this.topic});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {

  MultipleChoiceProvider? _multipleChoiceProvider;


  final userVocabDatabase=UserVocabDatabase();

  var listVocab=[];

  void init(){
    getLength(widget.topic.id);
    _multipleChoiceProvider?.trueValue=0;
    _multipleChoiceProvider?.falseValue=0;
    _multipleChoiceProvider?.progressValue=0;
    Provider.of<CounterProvider>(context, listen: false).shuffle=false;
    Provider.of<CounterProvider>(context, listen: false).autoSpeak=false;
    Provider.of<CounterProvider>(context, listen: false).position=false;
  }

  var result=TextEditingController();

  final historyDatabase=HistoryDatabase();

  var myFocusNode=FocusNode();

  Stopwatch stopwatch = Stopwatch();

  final date='${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}'
      ' ${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}:${DateTime.now().second.toString().padLeft(2,'0')}  ';

  var checkFalse=false;

  var checkTrue=false;

  var yourResult;

  var listEn=[];

  var listVi=[];

  late Future<List<Vocab>?> futureVocabs=vocabDatabase.fetchAllWithTopicRandomWithChoice(widget.topic.id,_multipleChoiceProvider!.progressValue);

  var mode=[];

  void fetchVocabs()async{
    var _listVocab=[];
    var _listVi=[];
    var _listEn=[];
    var data= Provider.of<CounterProvider>(context, listen: false).shuffle
        ?!Provider.of<CounterProvider>(context, listen: false).modeStudy?
    await vocabDatabase.fetchAllWithTopicRandom(widget.topic.id):await vocabDatabase.fetchAllWithTopicShuffleMarked(widget.topic.id)
        :!Provider.of<CounterProvider>(context, listen: false).modeStudy?
    await vocabDatabase.fetchAllWithTopic(widget.topic.id):await vocabDatabase.fetchAllWithTopicWithMark(widget.topic.id,true);
    if(data!=null) {
      for (var value in data) {
        _listVi.add(value.vi);
        _listEn.add(value.en);
        _listVocab.add(value);
      }
    }
    var dataVocab=vocabDatabase.fetchAllWithTopicRandomWithChoice(widget.topic.id,_multipleChoiceProvider!.progressValue);
    setState(() {
      futureVocabs=dataVocab;
      listEn=_listEn;
      listVi=_listVi;
      listVocab=_listVocab;
    });
  }

  late SharedPreferences prefs;

  var currentUser;

  UserVocabDatabaseRef userVocabDatabaseRef=UserVocabDatabaseRef();


  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();

  HistoryDatabaseRef historyDatabaseRef=HistoryDatabaseRef();

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
    }
  }

  void fetchVocab()async{

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchVocabs();
    init();
    getLength(widget.topic.id);
    stopwatch.start();
  }

  @override
  void dispose() {
    _multipleChoiceProvider?.trueValue=0;
    _multipleChoiceProvider?.falseValue=0;
    _multipleChoiceProvider?.progressValue=0;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _multipleChoiceProvider = Provider.of<MultipleChoiceProvider>(context, listen: false);
  }
  var listCount=0;


  final vocabDatabase=VocabDatabase();

  Future<int?> getLength(int topicId)async{
    var x=!Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.getLength(topicId):await vocabDatabase.getLengthMarked(topicId);
    setState(() {
      listCount=x!;
    });
   return x;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(icon:const Icon(Icons.close),onPressed: (){
          Navigator.pop(context);
        },),
        centerTitle: true,
        title:  Container(
            child: LinearPercentIndicator(
              lineHeight: 5.0,
              percent:listCount==0?0.0:_multipleChoiceProvider!.progressValue>listCount?1:(_multipleChoiceProvider!.progressValue)/listCount,
              progressColor: Colors.blue,
            )
        ),
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context)=>Dialog.fullscreen(
                child:_buildItemSetting(context)
            ));
          }, icon: const Icon(Icons.settings))
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child:Text(listVi.isNotEmpty&&_multipleChoiceProvider!.progressValue<listVi.length?!Provider.of<CounterProvider>(context, listen: false).position?listVi[_multipleChoiceProvider!.progressValue]:listEn[_multipleChoiceProvider!.progressValue]:'',style: const TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 40
        ),)),

        const SizedBox(
          height: 180,
        ),

        Expanded(child:FutureBuilder<List<Vocab>?>(
            future:vocabDatabase.fetchAllWithTopicRandomWithChoice(widget.topic.id,_multipleChoiceProvider!.progressValue),
            builder: (context,snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              else {
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Answers...', style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  );
                }
                else {
                  final vocabs = snapshot.data;
                  vocabs?.shuffle();
                  return
                    ListView.separated(itemBuilder: (context,index)=> InkWell(
                      onTap: ()async {
                        if (!checkTrue||!checkFalse) {
                          bool isCorrect =index<vocabs.length &&(!Provider.of<CounterProvider>(context, listen: false).position&&vocabs![index].en.toString() ==
                              listEn[
                              _multipleChoiceProvider!
                                  .progressValue
                              ]||Provider.of<CounterProvider>(context, listen: false).position&&vocabs![index].vi.toString() ==
                              listVi[
                              _multipleChoiceProvider!
                                  .progressValue
                              ]);
                          if (isCorrect) {
                            _multipleChoiceProvider!
                                .increaseTrueValue();
                            mode.add('right');
                            setState(() {
                              checkTrue = true;
                            });

                          } else {
                            _multipleChoiceProvider!
                                .increaseFalseValue();
                            mode.add('left');
                            setState(() {
                              checkTrue=true;
                              checkFalse=true;
                            });
                          }


                          await Future.delayed(const Duration(seconds: 2));

                          _multipleChoiceProvider!
                                .increaseProgressValue();

                          setState(() {
                            checkTrue = false;
                            checkFalse = false;
                          });

                          if (_multipleChoiceProvider!
                              .progressValue == listCount) {
                            addUserVocab(mode);
                            await _completeQuiz();
                          }
                        }
                      },
                      child:Stack(
                        children: [
                          checkTrue&&index<vocabs!.length&&!Provider.of<CounterProvider>(context, listen: false).position&&vocabs?[index].en.toString()==listEn[_multipleChoiceProvider!.progressValue]||checkTrue&&index<vocabs!.length&&Provider.of<CounterProvider>(context, listen: false).position&&vocabs?[index].vi.toString()==listVi[_multipleChoiceProvider!.progressValue]?const Positioned(child:Icon(Icons.check,color: Colors.green,),left: 320,top: 20,):checkFalse?const Positioned(child:Icon(Icons.close,color: Colors.red,),left: 320,top: 20,):Container(),
                        Container(
                          margin: const EdgeInsets.all(10),
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(width: 2, color: checkTrue&&index<vocabs!.length&&vocabs?[index].en.toString()==listEn[_multipleChoiceProvider!.progressValue]?Colors.green:checkFalse?Colors.red:Colors.blue)
                          ),
                          child: Text(
                              index<vocabs!.length&&!Provider.of<CounterProvider>(context, listen: false).position?vocabs[index].en.toString():index<vocabs!.length&&Provider.of<CounterProvider>(context, listen: false).position?vocabs[index].vi.toString():index>vocabs!.length?'chicken':'study',style: const TextStyle(
                            color: Colors.black,fontSize: 15,fontWeight: FontWeight.w400
                          ),)
                      ),
                      ]
                      )
                  ), separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 10,
                      );
                    }, itemCount: 4,

                    );
                }
              }
            }
        )
        ),

      ],
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
                          Provider.of<CounterProvider>(context, listen: false).changeShuffle();
                          fetchVocabs();
                          setState(() {
                            yourResult='';
                          });
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
                            setState(() {
                              yourResult='';
                            });
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
                            setState(() {
                              yourResult='';
                            });
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
              child: const Text('Hủy',style: TextStyle(
                  color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15
              ),),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _completeQuiz() async {
    result.clear();
    var data=await historyDatabase.create(
      typeTest: "multipleChoice",
      numCorrect: _multipleChoiceProvider
          !.trueValue,
      numIncorrect: _multipleChoiceProvider!
          .falseValue,
      timeComplete: stopwatch.elapsedMilliseconds,
      topicId: widget.topic.id,
      userId: 1,
      createdAt: date,
    );
    data ??= await historyDatabase.create(
        typeTest: "multipleChoice",
        numCorrect: _multipleChoiceProvider
        !.trueValue,
        numIncorrect: _multipleChoiceProvider!
            .falseValue,
        timeComplete: stopwatch.elapsedMilliseconds,
        topicId: widget.topic.id,
        userId:currentUser.id ,
        createdAt: date,
      );
    await historyDatabaseRef.addHistory(History(id: data, typeTest: "multipleChoice", numCorrect:  _multipleChoiceProvider
    !.trueValue, numIncorrect: _multipleChoiceProvider!
        .falseValue, createdAt: date, timeComplete: stopwatch.elapsedMilliseconds, userId: currentUser.id, topicId: widget.topic.id));

    stopwatch.reset();
    stopwatch.stop();
    final message=await Navigator.pushNamed(context, "/resultMultipleChoice", arguments: widget.topic);
    if(message!=null){
      init();
    }
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
