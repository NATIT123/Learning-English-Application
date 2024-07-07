import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Service/Sqlite/TopicDatabase.dart';
import '../Service/Sqlite/UserDatabase.dart';
import '../Service/Sqlite/VocabDatabase.dart';
import '../dto/Topic.dart';
import '../dto/UserDetail.dart';

class StudySet extends StatefulWidget {

  const StudySet({super.key});

  @override
  State<StudySet> createState() => _StudySetState();
}

class _StudySetState extends State<StudySet> {
  final topicDatabase=TopicDatabase();
  var message='';

  late Future<List<Topic>?> futureTopics;


  var userList=[];

  var listCount=[];

  final userDatabase=UserDatabase();

  final vocabDatabase=VocabDatabase();

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


  void fetchTopics() async {
    await getSharedPreferences();
    var _listCount=[];
    var _userList=[];
    var dataUser;
    var dataT=topicDatabase.fetchByUserId(currentUser.id);
    setState(() {
      futureTopics=dataT;
    });
    var data=await dataT;
    try{
      if(data!=null){
          for(var dataTopic in data){
            int? length = await getLength(dataTopic.id);
            _listCount.add(length!);
            dataUser=await userDatabase.fetchById(dataTopic.userId);
            _userList.add(dataUser);
          }
          setState(() {
            listCount=_listCount;
            userList=_userList;
          });
      }
    }catch(err){
      print(err);
    }
  }

  Future<int?> getLength(int topicId)async{
    var x= await vocabDatabase.getLength(topicId);
    return x;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopic(context);
  }


  Widget _buildTopic(BuildContext context){
    return  Container(
        margin: const EdgeInsets.all(10),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text('Học phần của bạn',style: TextStyle(
                  color: Colors.grey,
                fontSize: 20,fontWeight: FontWeight.bold,
              ),),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ) ,
              Expanded(child:FutureBuilder<List<Topic>?>(
                  future:topicDatabase.fetchByUserId(currentUser==null?0:currentUser.id),
                  builder: (context,snapshot){
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
                        final topics=snapshot.data!;
                        return ListView.separated(itemBuilder: (context,index)=>const SizedBox(
                          height: 12,
                        ),separatorBuilder: (context,index)=>
                            InkWell(
                              onTap: ()async{
                                final result=await Navigator.pushNamed(context,'/detailTopic',arguments: topics[index]);
                                fetchTopics();
                                if(result!=null){
                                  fetchTopics();
                                  setState(() {
                                    message=result.toString();
                                  });
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(SnackBar(content:
                                    Center(child:Text(message,)),
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
                              child:Card(
                              color: Colors.white,
                          child:Container(
                            padding:const EdgeInsets.all(10),
                            child:
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(topics[index].nameTopic ,style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  listCount.isNotEmpty&&index<listCount.length?Text("${listCount[index].toString()} thuật ngữ",style: const TextStyle(
                                      color: Colors.grey,fontSize: 12,fontWeight: FontWeight.bold
                                  ),
                                  ):const CircularProgressIndicator(
                                    color: Colors.black,
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
                                ]
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
                          )
                            ),

                        ) , itemCount: topics!.length+1);
                      }
                    }
                  }
              )
              )
            ]
        )
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


