import 'dart:ui';

import 'package:finalapp/Service/Sqlite/VocabDatabase.dart';
import 'package:finalapp/providers/type_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/counter_provider.dart';

class ResultTypeWord extends StatefulWidget {
  var topic;
  ResultTypeWord({super.key,required this.topic});

  @override
  State<ResultTypeWord> createState() => _ResultState();
}



class _ResultState extends State<ResultTypeWord> {
  var listCount=0;


  final vocabDatabase=VocabDatabase();

  Future<int?> getLength(int topicId)async{
    var x=!Provider.of<CounterProvider>(context, listen: false).modeStudy?await vocabDatabase.getLength(topicId):await vocabDatabase.getLengthMarked(topicId);
    setState(() {
      listCount=x!;
    });
  }

  var initStyle=const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLength(widget.topic.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('${Provider.of<TypeWordProvider>(context, listen: false).progressValue}/$listCount',style: const TextStyle(
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
        body: Column(
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
            ]
        )
    );
  }

  Widget _buildBody(BuildContext context){
    return SingleChildScrollView(child:Column(
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
                percent:Provider.of<TypeWordProvider>(context, listen: false).trueValue==listCount?1.0:Provider.of<TypeWordProvider>(context, listen: false).falseValue==listCount?0.0:listCount==0?0.0:Provider.of<TypeWordProvider>(context, listen: false).trueValue/listCount,
                center:Provider.of<TypeWordProvider>(context, listen: false).falseValue==listCount?const Text(
                  "0%",
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ):Provider.of<TypeWordProvider>(context, listen: false).trueValue==listCount
                    ? const Icon(Icons.check,color: Colors.green,):listCount==0?const Text('0.0'):Text('${((Provider.of<TypeWordProvider>(context, listen: false).trueValue/listCount)*100).toInt()}%'),
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
                        child:Center(child:Text('${Provider.of<TypeWordProvider>(context, listen: false).trueValue}',style: const TextStyle(
                            color: Colors.green,fontWeight: FontWeight.bold
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
                        child:Center(child:Text('${Provider.of<TypeWordProvider>(context, listen: false).falseValue}',style: const TextStyle(
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
          height: 50,
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
                }, child: Text('Làm lại bài gõ từ',style: initStyle,))
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


      ],
    )
    );
  }

}
