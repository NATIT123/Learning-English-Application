import 'dart:typed_data';

import 'package:finalapp/Service/Sqlite/HistoryDatabase.dart';
import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:finalapp/dto/History.dart';
import 'package:flutter/material.dart';
class LeaderBoard extends StatefulWidget {

  var list;
  LeaderBoard({super.key,required this.list});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {

  final historyDatabase=HistoryDatabase();
  final userDatabase=UserDatabase();

  var userList=[];

  late Future<List<History>?> futureHistory;

  var initStyle=const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15
  );



  void fetchHistory()async{
    var data=historyDatabase.fetchByTypeTest(widget.list[0], widget.list[1]);
    setState(() {
      futureHistory=data;
    });
    var userData;
    var _userList=[];
    var dataHistory=await data;
    if(dataHistory!=null) {
      for (var data in dataHistory) {
          userData=await userDatabase.fetchById(data.userId);
          _userList.add(userData);
      }
      setState(() {
        userList=_userList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.list[0]);
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Leaderboard',style: TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body:_buildBody(context) ,
    );
  }

  Widget _buildBody(BuildContext context){
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          height: 200,
           child:Center(child:Image.asset( "images/firstCup.png",fit: BoxFit.cover,),)),
        Container(
          margin: const EdgeInsets.all(5),
        child:const Divider(
          thickness: 2,
          color: Colors.black,
        )
        ),
        _buildListItem(context)
      ],
    );
  }

  Widget _buildListItem(BuildContext context){
    return   Expanded(child:FutureBuilder<List<History>?>(
        future:futureHistory,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else{
            if(snapshot.data==null||snapshot.data!.isEmpty){
              return const Center(
                child: Text('No Users Found...',style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                ),
              );
            }
            else{
              final histories=snapshot.data!;
              return ListView.separated(itemBuilder: (context,index)=>const SizedBox(
                height: 10,
              ),separatorBuilder: (context,index)=>
                  Container(
                    margin: const EdgeInsets.all(10),
                  child:Card(
                        color: Colors.white,
                        child:ListTile(
                          leading:userList.isNotEmpty&&index<userList.length?convertImage(userList[index].imgPath.toString()):Text('',style: initStyle,),
                          title: Text(userList.isNotEmpty&&index<userList.length?'${userList[index].userName}':'',style: initStyle,),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(histories.isNotEmpty&&index<histories.length?'Correct: ${histories[index].numCorrect}':'',style: const TextStyle(
                                  color: Colors.grey,fontWeight: FontWeight.bold
                              ),),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(histories.isNotEmpty&&index<histories.length?'Incorrect: ${histories[index].numIncorrect}':'',style: const TextStyle(
                                  color: Colors.grey,fontWeight: FontWeight.bold
                              ),),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(histories.isNotEmpty&&index<histories.length?'Time: ${convertMilliseconds(histories[index].timeComplete)}':'',style: const TextStyle(
                                color: Colors.grey,fontWeight: FontWeight.bold
                              ),),
                            ],
                          ),
                        trailing: index==0?Image.asset("images/medal.png"):index==1?Image.asset("images/medal2.png"):index==2?Image.asset("images/medal3.png"):null,
                        )
                    )), itemCount: histories!.length+1,);
            }
          }
        }
    )
    );
  }

  Widget convertImage(image){
    return !image.contains("http") && !image.contains("images")
        ? CircleAvatar(
      radius: 30,
      backgroundImage: MemoryImage(convertStringToUint8List(image)),
    )
        : CircleAvatar(
      radius: 30,
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

  String convertMilliseconds(int milliseconds){
    int seconds = milliseconds ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    int remainingSeconds = seconds % 60;
    int remainingMinutes = minutes % 60;
    String convert='';

    if(hours>0){
      convert+='$hours hours';
    }

    if(remainingMinutes>0){
      convert+='$remainingMinutes minutes';
    }
    if(remainingSeconds>0){
      convert+='$remainingSeconds seconds';
    }

    return convert;
  }



}
