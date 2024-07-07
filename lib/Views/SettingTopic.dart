import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
class SettingTopic extends StatefulWidget {
  const SettingTopic({super.key});

  @override
  State<SettingTopic> createState() => _SettingTopicState();
}

class _SettingTopicState extends State<SettingTopic> {

  var isView=['Chỉ tôi','Mọi người'];

  var isDropDownView='Chỉ tôi';
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.black,),onPressed: (){
            Navigator.pop(context,isDropDownView);
          },),
          title: const Text('Cài đặt tùy chọn',style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),),
        ),
      body:Container(
      color: Colors.white,
      child:Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Quyền riêng tư',style: TextStyle(
                color: Colors.grey,fontSize: 15,fontWeight: FontWeight.w500
              ),),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ai có thể xem',style: TextStyle(
                    color: Colors.black,fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),),
                  const SizedBox(width: 100,),
                  _buildDropDown(context)
                ]
              ),

                const SizedBox(
                  height: 20,
                ),


                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ai có thể chỉnh sửa',style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),),
                      SizedBox(width: 100,),
                      Text('Chỉ tôi',style: TextStyle(
                          color: Colors.blue,fontSize: 15,fontWeight: FontWeight.bold
                      ),
                      )
                    ]
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                    child:const Text(
                      'Xóa học phần',style: TextStyle(
                      color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showDialog(context: context, builder: (context)=>_buildAlertDialog(context));
                },
                  )),

        ]
            ),
          )
        ],
      )
      ),
    );
  }

  Widget _buildDropDown(BuildContext context){
    return
      SizedBox(
    width: 140,
      child:DropdownButtonFormField(
        decoration: const InputDecoration(
          focusColor: Colors.black,
            focusedBorder:UnderlineInputBorder(
                borderSide: BorderSide(color:Colors.black)
            ) ,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Colors.black)
            ),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Colors.black)
          ),
        ),
        value: isDropDownView,
        iconSize: 0.0,
        items:isView.map((element)=>
            DropdownMenuItem(value: element,child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(element,style: const TextStyle(
                  color: Colors.blue,fontWeight: FontWeight.bold
                ),),
                SizedBox(
                  width: element=='Mọi người'?40:65,
                ),
                isDropDownView==element ?const Icon(Icons.check):Container(),
              ],
            )
            )).toList(), onChanged:(String? value)=>{
      setState(() {
        isDropDownView=value!;
      })

    })
      )
    ;
  }

  Widget _buildAlertDialog(BuildContext context){
    return AlertDialog(
      title:const Text('Xóa chủ đề') ,
      content: const Text('Bạn chắc chắn muốn xóa học phần này vĩnh viễn?'),
      actions: [
        TextButton(onPressed: ()=>{
          Navigator.pop(context),
        }, child: const Text('HỦY')
        ),
        TextButton(onPressed: () async=>{
          Navigator.popUntil(context, ModalRoute.withName('/'))
        },
            child: const Text('XÓA')
        )
      ],
    );
  }
}
