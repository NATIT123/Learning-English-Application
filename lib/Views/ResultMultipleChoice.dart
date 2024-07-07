import 'dart:convert';
import 'dart:ui';

import 'package:finalapp/Service/Firebase/VocabDatabaseRef.dart';
import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:finalapp/Service/Sqlite/VocabDatabase.dart';
import 'package:finalapp/dto/Vocab.dart';
import 'package:finalapp/providers/multiple_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Firebase/TopicDatabaseRef.dart';
import '../dto/UserDetail.dart';
import '../providers/counter_provider.dart';

class ResultMultipleChoice extends StatefulWidget {
  var topic;
  ResultMultipleChoice({super.key,required this.topic});

  @override
  State<ResultMultipleChoice> createState() => _ResultState();
}



class _ResultState extends State<ResultMultipleChoice> {
  var listCount=0;

  FlutterTts flutterTts=FlutterTts();

  final userDatabase=UserDatabase();

  late Future<List<Vocab>?> futureVocabs;

  var modeStudy=false;

  var row=0;

  late SharedPreferences prefs;

  var currentUser;


  TopicDatabaseRef topicDatabaseRef=TopicDatabaseRef();

  VocabDatabaseRef vocabDatabaseRef=VocabDatabaseRef();

  getSharedPreferences()async{
    prefs=await SharedPreferences.getInstance();
    String? currents=prefs.getString("user");
    if(currents!=null){
      setState(() {
        currentUser=UserDetail.fromJson(json.decode(currents));
      });
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

  Future<void>speak(String text) async{
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void fetchVocabs() async{
    var dataVocab=vocabDatabase.fetchAllWithTopic((widget.topic.id));
    setState(() {
      futureVocabs=dataVocab;
    });
  }


  final vocabDatabase=VocabDatabase();

  Future<int?> getLength(int topicId)async{
    var x=!Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.getLength(topicId):await vocabDatabase.getLengthMarked(topicId);
    setState(() {
      listCount=x!;
    });
  }

  var checkMark=false;

  var initStyle=const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    fetchVocabs();
    getLength(widget.topic.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('${Provider.of<MultipleChoiceProvider>(context, listen: false).progressValue}/$listCount',style: const TextStyle(
              color: Colors.black,fontWeight: FontWeight.bold
          ),),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: (){
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
        body:Container(
            height: 5000,
            child:Column(
            children: [
              Container(
                  child: LinearPercentIndicator(
                    width: 360,
                    lineHeight: 5.0,
                    percent:1,
                    progressColor: Colors.blue,
                  )
              ),
              Expanded(child:_buildBody(context)),
              // SizedBox(
              //   width: 10,
              // height: 10,
              // child:_buildItemVocab(context)
              // )
            ]
        )
        )
    );
  }

  Widget _buildBody(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              width: 20,
            ),
            const Expanded(
                child:Text('Chà, bạn nắm bài thật chắc! Hãy thử tự kiểm tra để ôn luyện thêm',style: TextStyle(
                    color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                ),softWrap: true)),
            Container(
                color: Colors.white,
                width: 200,
                child:Image.asset("images/congratulation.jpg",fit: BoxFit.cover,))
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: CircularPercentIndicator(
                radius: 50,
                lineWidth: 12,
                animation: true,
                percent:Provider.of<MultipleChoiceProvider>(context, listen: false).trueValue==listCount?1.0:Provider.of<MultipleChoiceProvider>(context, listen: false).falseValue==listCount?0.0:listCount==0?0.0:Provider.of<MultipleChoiceProvider>(context, listen: false).trueValue/listCount,
                center:Provider.of<MultipleChoiceProvider>(context, listen: false).falseValue==listCount?const Text(
                  "0%",
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ):Provider.of<MultipleChoiceProvider>(context, listen: false).trueValue==listCount
                    ? const Icon(Icons.check,color: Colors.green,):listCount==0?const Text('0.0'):Text('${((Provider.of<MultipleChoiceProvider>(context, listen: false).trueValue/listCount)*100).toInt()}%'),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor:Colors.green,
                backgroundColor: Colors.orange,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    const Text('Đúng',style: TextStyle(
                        color: Colors.green,fontSize: 18,fontWeight: FontWeight.bold
                    ),),
                    const SizedBox(
                      width: 110,
                    ),
                    Container(
                        width: 20,
                        decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.green,
                                width: 1
                            )
                        ),
                        child:Center(child:Text('${Provider.of<MultipleChoiceProvider>(context, listen: false).trueValue}',style: const TextStyle(
                            color: Colors.green,fontWeight: FontWeight.bold,
                        ),))),
                  ],
                ),
                Row(
                  children: [
                    const Text('Sai',style: TextStyle(
                        color: Colors.orange,fontSize: 18,fontWeight: FontWeight.bold
                    ),),
                    const SizedBox(
                      width: 128,
                    ),
                    Container(
                        width: 20,
                        decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.orange,
                                width: 1
                            )
                        ),
                        child:Center(child:Text('${Provider.of<MultipleChoiceProvider>(context, listen: false).falseValue}',style: const TextStyle(
                            color: Colors.orange,fontSize: 15,fontWeight: FontWeight.bold
                        ),),)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Còn lại',style: TextStyle(
                        color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold
                    ),),
                    const SizedBox(
                      width: 98,
                    ),
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.grey,
                              width: 1
                          )
                      ),
                      child:const Center(child:Text('0',style: TextStyle(
                          color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                      ),),),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.all(10),
          width: double.infinity,
          child:ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context,'SUCCESS');
              }, child: Text('Quay lại chế độ học',style: initStyle)),
        ),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            child:ElevatedButton(
                style:ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )
                ),
                onPressed: (){
                  Navigator.pop(context,'SUCCESS');
                }, child: Text('Làm lại bài trắc nghiệm',style: initStyle,))
        ),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            child:ElevatedButton(
                style:ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )
                ),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context,'Back to StudySet');
                }, child: Text('Quay lại trang chủ đề',style: initStyle,))
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
        child:const Text('Số thuật ngữ đã học',style: TextStyle(
            color: Colors.grey,fontWeight: FontWeight.bold
        ),)
        ),
        Expanded(child:_buildItemVocab(context))

      ],
    );
  }

  Widget _buildItemVocab(BuildContext context){
    return  SizedBox(
        width: double.infinity,
        child:FutureBuilder<List<Vocab>?>(
        future:futureVocabs,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else{
            if(snapshot.data==null||snapshot.data!.isEmpty){
              return const Center(
                child: Text('No vocabs...',style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                ),
              );
            }
            else{
              final vocabs=snapshot.data!;
              return ListView.separated(itemBuilder: (context,index)=>Container(
                margin: const EdgeInsets.all(10),
                  child:Card(
                      color: Colors.white,
                      child:Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment:  MainAxisAlignment.spaceBetween  ,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vocabs.isNotEmpty&&index<vocabs.length?vocabs[index].vi:'',style: const TextStyle(
                                color: Colors.black,fontWeight: FontWeight.bold
                              ),),Text(vocabs.isNotEmpty&&index<vocabs.length? vocabs[index].en.toString():'',style: const TextStyle(
                                  color: Colors.black,fontWeight: FontWeight.bold
                              ),),
                            ],
                          ),
                          Row(
                              children: [
                                IconButton(onPressed: (){
                                  flutterTts.speak(vocabs[index].en.toString());
                                }, icon: const Icon(Icons.headphones)) ,
                                IconButton(onPressed: ()async{
                                  await vocabDatabase.update(id: vocabs[index].id,
                                      en:vocabs[index].en,
                                      vi:vocabs[index].vi,
                                      isMark:!vocabs[index].isMark
                                  );
                                  await vocabDatabaseRef.updateVocab(vocabs[index].id, vocabs[index].en, vocabs[index].vi, !vocabs[index].isMark);
                                  fetchVocabs();
                                  checkMode();
                                }, icon: Icon(vocabs[index].isMark?Icons.star:Icons.star_border))
                              ]
                          )
                        ],
                      )
                  )
              ),separatorBuilder: (context,index)=> const SizedBox(
                height:0,
              )
                  , itemCount: vocabs!.length);
            }
          }
        }
    )
    );
  }
}
