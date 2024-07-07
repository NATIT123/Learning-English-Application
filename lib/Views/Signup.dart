import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../Service/Firebase/Auth.dart';
import '../Service/Firebase/UserDatabaseRef.dart';
import '../dto/UserDetail.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var _obscureText = true;
  final _formkey = GlobalKey<FormState>();

  UserDatabaseRef databaseRef = UserDatabaseRef();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final userDatabase=UserDatabase();

  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text("Đăng ký",
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )),
          ),
          body:
          Stack(
            children:[
          SingleChildScrollView(
            child:Column(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset(
                            "images/english.jpg",
                            fit: BoxFit.cover,
                          )),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return 'Tên tài khoản không được để trống!';
                                    }else if(value.length<4){
                                      return 'Tên tài khoản quá ngắn!';
                                    }
                                    return null;
                                  },
                                  autofocus: true,
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.account_box_rounded),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      hintText: "Nhập tên tài khoản",
                                      labelText: "Tên tài khoản",
                                      labelStyle: TextStyle(
                                        color: Colors.blue
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return 'Email không được để trống!';
                                    }else if(value.length<6){
                                      return 'Email quá ngắn!';
                                    }else if(!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                        .hasMatch(value)){
                                      return 'Email không hợp lệ!';
                                    }
                                    return null;
                                  },
                                  controller: mailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      prefixIcon: Icon(Icons.mail),
                                      border: OutlineInputBorder(),
                                      hintText: "Nhập email",
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                        color: Colors.blue
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return 'Mật khẩu không được để trống!';
                                    }else if(value.length < 6 || value.length > 30){
                                      return 'Độ dài mật khẩu phải từ 6 đến 30 ký tự!';
                                    }else if(!RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).*$")
                                        .hasMatch(value)){
                                      return 'Mật khẩu phải chứa ít nhất 1 ký tự hoa, 1 ký tự thường,'
                                          '\n1 chữ số và 1 ký tự đặc biệt!';
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
                                  obscureText: _obscureText,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      prefixIcon: const Icon(Icons.password),
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: Icon(
                                          _obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.black,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      hintText: "Nhập mật khẩu",
                                      labelText: "Mật khẩu",
                                      labelStyle: const TextStyle(
                                        color: Colors.blue
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return 'Mật khẩu xác thực không được để trống!';
                                    }else if(value.toString() != passwordController.text){
                                      return 'Mật khẩu xác thực không khớp!';
                                    }
                                    return null;
                                  },
                                  controller: repasswordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: const InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      prefixIcon: Icon(Icons.lock),
                                      border: OutlineInputBorder(),
                                      hintText: "Nhập lại mật khẩu",
                                      labelText: "Mật khẩu xác thực",
                                      labelStyle: TextStyle(
                                        color: Colors.blue
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              InkWell(
                                onTap: ()async{
                                  if(_formkey.currentState!.validate()){
                                    var message=await register(context);
                                    if(message=='Đăng ký thành công!'&&message!=null){
                                      setState(() {
                                        isLoading=true;
                                      });
                                      Future.delayed(const Duration(seconds: 2), () {
                                        setState(() {
                                          isLoading=false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString(),style: const TextStyle(
                                            color:Colors.black,fontWeight: FontWeight.bold
                                        ),), backgroundColor: Colors.blue,));
                                        Navigator.pushNamed(context,'/');
                                      });
                                    }
                                    else{
                                      setState(() {
                                        isLoading=false;
                                      });
                                    }
                                  }
                                },
                                child: Ink(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 30.0),
                                    decoration: BoxDecoration(
                                        color: Colors.indigo[900],
                                        borderRadius: BorderRadius.circular(30)),
                                    child: const Center(
                                        child: Text(
                                          "Đăng ký",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold),
                                        ))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "hoặc Đăng nhập bằng",
                        style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 22.0,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              AuthService().signInWithGoogle(context);
                            },
                            child: Image.asset(
                              "images/google.png",
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // const SizedBox(
                          //   width: 30.0,
                          // ),
                          // GestureDetector(
                          //   onTap: (){
                          //     // AuthMethods().signInWithApple();
                          //   },
                          //   child: Image.asset(
                          //     "images/apple.png",
                          //     height: 50,
                          //     width: 50,
                          //     fit: BoxFit.cover,
                          //   ),
                          // )
                        ],
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Đã có tài khoản?",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 5.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context,'/login');
                            },
                            child: Text(
                              "Đăng nhập",
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                  ],
                  )
            ),
              _buildViewSubmit(context, isLoading),
    ]
    )
        );
  }

  register(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mailController.text, password: passwordController.text);
      var id = await userDatabase.create(fullName: nameController.text, userName: mailController.text.substring(0,mailController.text.indexOf('@')), email: mailController.text, password: passwordController.text, imgPath: 'images/avatar.png');
      id ??= await userDatabase.create(fullName: nameController.text, userName: mailController.text.substring(0,mailController.text.indexOf('@')), email: mailController.text, password: passwordController.text, imgPath: 'images/avatar.png');
      print('User created in SQLite with id: $id');
      UserDetail user = UserDetail(fullName: nameController.text, userName: mailController.text.substring(0,mailController.text.indexOf('@')), email: mailController.text,
          imgPath: 'images/avatar.png', id: id??0);
      databaseRef.addUserDetail(user);
      return "Đăng ký thành công!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Mật khẩu yếu!",
            )));
        return "Mật khẩu yếu!";
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Tài khoản đã tồn tại!",
            )));
        return "Tài khoản đã tồn tại!";
      }
    }
  }
  Widget _buildViewSubmit(BuildContext context,_isLoading){
    if(_isLoading){
      return Container(
        // width: double.infinity,
        height: double.infinity,
        color: Colors.white.withOpacity(0.5),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.blue,),
              SizedBox(height: 20.0),
              Text('Connecting to backend server...',style: TextStyle(
                  color: Colors.black,fontSize: 20
              ),),
            ],
          ),
        ),
      );
    }
    return Container();
  }

}
