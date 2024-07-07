import 'dart:convert';

import 'package:finalapp/Service/Sqlite/HistoryDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserVocabDatabase.dart';
import 'package:finalapp/Service/Sqlite/VocabDatabase.dart';
import 'package:finalapp/providers/type_words.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Firebase/HistoryDatabaseRef.dart';
import '../Service/Firebase/TopicDatabaseRef.dart';
import '../Service/Firebase/UserVocabDatabaseRef.dart';
import '../dto/History.dart';
import '../dto/UserDetail.dart';
import '../dto/UserVocab.dart';
import '../providers/counter_provider.dart';

class TypeWord extends StatefulWidget {
  var topic;
  TypeWord({super.key,required this.topic});

  @override
  State<TypeWord> createState() => _TypeWordState();
}

class _TypeWordState extends State<TypeWord> {

  void init(){
    getLength(widget.topic.id);
    Provider.of<TypeWordProvider>(context, listen: false).trueValue=0;
    Provider.of<TypeWordProvider>(context, listen: false).falseValue=0;
    Provider.of<TypeWordProvider>(context, listen: false).progressValue=0;
    Provider.of<CounterProvider>(context, listen: false).shuffle=false;
    Provider.of<CounterProvider>(context, listen: false).autoSpeak=false;
    Provider.of<CounterProvider>(context, listen: false).position=false;
  }

  var result=TextEditingController();

  final historyDatabase=HistoryDatabase();

  var myFocusNode=FocusNode();

  Stopwatch stopwatch = Stopwatch();

  final userVocabDatabase=UserVocabDatabase();

  final date='${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}'
      ' ${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}:${DateTime.now().second.toString().padLeft(2,'0')}  ';

  var checkFalse=false;

  var checkTrue=false;

  var yourResult;

  var listEn=[];

  var listVi=[];

  var now;

  var listVocab=[];

  var mode=[];

  void fetchVocabs()async{
    var _listVi=[];
    var _listEn=[];
    var _listVocab=[];
    var data= Provider.of<CounterProvider>(context, listen: false).shuffle
        ?!Provider.of<CounterProvider>(context, listen: false).modeStudy?
    await vocabDatabase.fetchAllWithTopicRandom(widget.topic.id):await vocabDatabase.fetchAllWithTopicShuffleMarked(widget.topic.id)
        :!Provider.of<CounterProvider>(context, listen: false).modeStudy?
    await vocabDatabase.fetchAllWithTopic(widget.topic.id):await vocabDatabase.fetchAllWithTopicWithMark(widget.topic.id,true);
    if(data!=null) {
      for (var value in data) {
          _listVocab.add(value);
          _listVi.add(value.vi);
          _listEn.add(value.en);
      }
    }
    setState(() {
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    init();
    fetchVocabs();
    getLength(widget.topic.id);
    now=DateTime.now();
    stopwatch.start();
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  var listCount=0;

  final vocabDatabase=VocabDatabase();

  Future<int?> getLength(int topicId)async{
    var x=!Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.getLength(topicId):await vocabDatabase.getLengthMarked(topicId);
    setState(() {
      listCount=x!;
    });
    print(listCount);
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
              percent:listCount==0?0.0:Provider.of<TypeWordProvider>(context, listen: false).progressValue>listCount?1:(Provider.of<TypeWordProvider>(context, listen: false).progressValue)/listCount,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child:Text(listVi.isNotEmpty&&Provider.of<TypeWordProvider>(context, listen: false).progressValue<listVi.length?!Provider.of<CounterProvider>(context, listen: false).position?listVi[Provider.of<TypeWordProvider>(context, listen: false).progressValue]:listEn[Provider.of<TypeWordProvider>(context, listen: false).progressValue]:'',style: const TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 40
        ),)),

        const SizedBox(
          height: 80,
        ),

        checkFalse?Center(child:Text('Đáp án đúng: ${!Provider.of<CounterProvider>(context, listen: false).position&&listEn.isNotEmpty&&Provider.of<TypeWordProvider>(context, listen: false).progressValue<listEn.length?listEn[Provider.of<TypeWordProvider>(context, listen: false).progressValue]:Provider.of<CounterProvider>(context, listen: false).position&&listVi.isNotEmpty&&Provider.of<TypeWordProvider>(context, listen: false).progressValue<listVi.length?listVi[Provider.of<TypeWordProvider>(context, listen: false).progressValue]:''} ',style: const TextStyle(
          color: Colors.green,fontWeight: FontWeight.bold
        ),)):Container(),
        const SizedBox(
          height: 20,
        ),
        checkFalse?Center(child:Text('Đáp án của bạn:  ${yourResult??''} ',style: const TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold
        ),)):Container(),

        const SizedBox(
          height: 200,
        ),

        Container(
          margin: const EdgeInsets.all(10),
        child:TextFormField(
          onChanged: (String? value)async{
              if(checkFalse){
                  if(!Provider.of<CounterProvider>(context, listen: false).position&&listEn[Provider.of<TypeWordProvider>(context, listen: false).progressValue].toString().trim().toLowerCase()==value.toString().trim().toLowerCase()){
                    Future.delayed(const Duration(seconds: 2), () async {
                      Provider.of<TypeWordProvider>(context, listen: false)
                          .increaseProgressValue();
                      Provider.of<TypeWordProvider>(context, listen: false)
                          .increaseFalseValue();
                      mode.add('left');
                      if (Provider
                          .of<TypeWordProvider>(context, listen: false)
                          .progressValue == listCount) {
                        result.clear();
                      await completeQuiz();
                      }
                      result.clear();
                      setState(() {
                        checkFalse = false;
                        yourResult = '';
                      });
                    });
                  }
                  else if(Provider.of<CounterProvider>(context, listen: false).position &&listVi[Provider.of<TypeWordProvider>(context, listen: false).progressValue].toString().trim().toLowerCase()==value.toString().trim().toLowerCase()){
                    Future.delayed(const Duration(seconds: 2), () async {
                      Provider.of<TypeWordProvider>(context, listen: false)
                          .increaseProgressValue();
                      Provider.of<TypeWordProvider>(context, listen: false)
                          .increaseFalseValue();
                      mode.add('left');
                      if (Provider
                          .of<TypeWordProvider>(context, listen: false)
                          .progressValue == listCount) {
                        result.clear();
                       await completeQuiz();
                      }
                      result.clear();
                      setState(() {
                        checkFalse = false;
                        yourResult = '';
                      });
                    });
                  }
              }
          },
          keyboardType: TextInputType.text,
          controller: result,
          readOnly: checkTrue,
          onFieldSubmitted:(String ?value){
            if(!checkFalse) {
              if (!Provider
                  .of<CounterProvider>(context, listen: false)
                  .position&&listEn.isNotEmpty&&Provider
                  .of<TypeWordProvider>(context, listen: false)
                  .progressValue<listEn.length&&listEn[Provider
                  .of<TypeWordProvider>(context, listen: false)
                  .progressValue].toString().toLowerCase().trim() == value.toString().trim().toLowerCase()) {
                mode.add("right");
                setState(() {
                  checkFalse=false;
                  checkTrue = true;
                  yourResult = value;
                });
                Future.delayed(const Duration(seconds: 2), ()async {
                  Provider.of<TypeWordProvider>(context, listen: false)
                      .increaseProgressValue();
                  Provider.of<TypeWordProvider>(context, listen: false)
                      .increaseTrueValue();
                  if (Provider
                      .of<TypeWordProvider>(context, listen: false)
                      .progressValue == listCount) {
                    result.clear();
                   await completeQuiz();
                  }
                  setState(() {
                    checkFalse=false;
                    checkTrue = false;
                    yourResult = '';
                  });// Prints after 1 second.
                });
              }
              else if (Provider
                  .of<CounterProvider>(context, listen: false)
                  .position&&listVi.isNotEmpty&&Provider
                  .of<TypeWordProvider>(context, listen: false)
                  .progressValue<listVi.length&&listVi[Provider
                  .of<TypeWordProvider>(context, listen: false)
                  .progressValue].toString().toLowerCase().trim() == value.toString().trim().toLowerCase()) {
                mode.add("right");
                setState(() {
                  checkFalse=false;
                  checkTrue = true;
                  yourResult = value;
                });
                Future.delayed(const Duration(seconds: 2), ()async {
                  Provider.of<TypeWordProvider>(context, listen: false)
                      .increaseProgressValue();
                  Provider.of<TypeWordProvider>(context, listen: false)
                      .increaseTrueValue();
                  if (Provider
                      .of<TypeWordProvider>(context, listen: false)
                      .progressValue == listCount) {
                    result.clear();
                    await completeQuiz();
                  }
                  setState(() {
                    checkFalse=false;
                    checkTrue = false;
                    yourResult = '';
                  });// Prints after 1 second.
                });
              }
              else {
                setState(() {
                  checkFalse = true;
                  yourResult = value;
                });
              }
              result.clear();
              myFocusNode.requestFocus();
            }
          },
          autofocus: true,
          focusNode: myFocusNode,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
    ),
              focusedBorder: const OutlineInputBorder(
                borderSide:  BorderSide(color: Colors.blue),
              ),
            border: const OutlineInputBorder(
            ),
            labelText: 'Enter your result',
            labelStyle: const TextStyle(
              color: Colors.black
            ),
            suffix: TextButton(
              onPressed: () {
                Provider.of<TypeWordProvider>(context, listen: false).increaseFalseValue();
                setState(() {
                  checkFalse=true;
                });
              },
              child:checkTrue?IconButton(onPressed: () {  }, icon: const Icon(Icons.check,color: Colors.green,),
              ):checkFalse?IconButton(onPressed: () {  }, icon: const Icon(Icons.close,color: Colors.red,),
              ): const Text('Không biết',style: TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold
              ),),
            )
          ),
        )
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child:checkTrue?const Text('Bạn đã nhập đáp án đúng',style: TextStyle(
              color: Colors.green,fontWeight: FontWeight.bold
          ),):checkFalse?const Text('Viết câu trả lời đúng',style:TextStyle(
              color: Colors.red,fontWeight: FontWeight.bold
          ),):!Provider.of<CounterProvider>(context, listen: false).position?const Text('Nhập bằng tiếng anh',style: TextStyle(
            color: Colors.black,fontWeight: FontWeight.bold
          ),):const Text('Nhập bằng tiếng việt',style: TextStyle(
              color: Colors.black,fontWeight: FontWeight.bold
          ),),
        )
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

  Future<void> completeQuiz()async{
    var data=await historyDatabase.create(typeTest: "typeWord", numCorrect:Provider.of<TypeWordProvider>(context, listen: false).trueValue , numIncorrect:Provider.of<TypeWordProvider>(context, listen: false).falseValue, timeComplete:stopwatch.elapsedMilliseconds , topicId: widget.topic.id, userId: 1, createdAt: date);
    data??await historyDatabase.create(typeTest: "typeWord", numCorrect:Provider.of<TypeWordProvider>(context, listen: false).trueValue , numIncorrect:Provider.of<TypeWordProvider>(context, listen: false).falseValue, timeComplete:stopwatch.elapsedMilliseconds , topicId: widget.topic.id, userId: 1, createdAt: date);
    historyDatabaseRef.addHistory(History( typeTest: "typeWord",
      numCorrect: Provider.of<TypeWordProvider>(context, listen: false).trueValue,
      numIncorrect: Provider.of<TypeWordProvider>(context, listen: false).falseValue,
      timeComplete: stopwatch.elapsedMilliseconds,
      topicId: widget.topic.id,
      userId:currentUser.id ,
      createdAt: date, id: data,));
    stopwatch.reset();
    stopwatch.stop();
    addUserVocab(mode);
    Navigator.pushNamed(context, "/resultTypeWord",arguments: widget.topic);
  }


}
