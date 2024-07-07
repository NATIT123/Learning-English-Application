import 'dart:convert';

import 'package:finalapp/Service/Sqlite/UserDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Service/Firebase/Auth.dart';
import '../Service/Firebase/SharedPref.dart';
import '../Service/Sqlite/DataBaseService.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  var _obscureText = true;
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  bool isLoading1=false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPrefService sharedPref = SharedPrefService();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final userDatabase=UserDatabase();


  Future<void> getDatabase()async{
    await DataBaseService().database;
  }

  @override
  void initState() {
    initHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text("Đăng nhập",
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                )),
          ),
          body:
          Stack(
    children:[
          Center(
            child: SingleChildScrollView(
              child: Builder(
                  builder: (context) {
                    return isLoading ? buildLoadingScreen(context)
                        :Column(
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
                                        return 'Email không được để trống!';
                                      }else if(!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                          .hasMatch(value)){
                                        return 'Email không hợp lệ!';
                                      }
                                      return null;
                                    },
                                    autofocus: true,
                                    controller: mailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        prefixIcon: Icon(Icons.mail),
                                        border: OutlineInputBorder(

                                        ),
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
                                      }
                                      return null;
                                    },
                                    controller: passwordController,
                                    obscureText: _obscureText,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
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
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        border: const OutlineInputBorder(),
                                        hintText: "Nhập mật khẩu",
                                        labelText: "Mật khẩu",
                                        labelStyle: const TextStyle(
                                        color: Colors.blue
                                      )
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    if(_formkey.currentState!.validate()){
                                      setState(() {
                                        email = mailController.text;
                                        password = passwordController.text;
                                      });
                                    }
                                    var message=await login(context);
                                    if(message=='Đăng nhập thành công'&&message!=null){
                                      setState(() {
                                        isLoading1=true;
                                      });
                                      var user=await userDatabase.fetchByEmail(email);
                                      sharedPref.write(key: "user", value: jsonEncode(user?.toJson()));
                                      sharedPref.write(key: "pw", value: passwordController.text);
                                      Future.delayed(const Duration(seconds: 2), () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString(),style: const TextStyle(
                                            color:Colors.black,fontWeight: FontWeight.bold
                                        ),), backgroundColor: Colors.blue,));
                                        Navigator.pushNamed(context, '/home');
                                      });
                                    }
                                    else{
                                      setState(() {
                                        isLoading1 = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 30.0),
                                      decoration: BoxDecoration(
                                          color: Colors.indigo[900],
                                          borderRadius: BorderRadius.circular(30)),
                                      child: const Center(
                                          child: Text(
                                            "Đăng nhập",
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
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: const Text("Quên mật khẩu?",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "hoặc Đăng nhập bằng",
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  isLoading = true;
                                });
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
                            const Text("Không có tài khoản?",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              width: 5.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                "Đăng ký",
                                style: TextStyle(
                                    color: Colors.indigo[900],
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  }
              ),
            ),
          ),
      _buildViewSubmit(context,isLoading1)
    ]
    )
        );
  }

  login(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Đăng nhập thành công";
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Tài khoản không tồn tại!",
            )));
        return "Tài khoản không tồn tại!";
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Sai mật khẩu!",
            )));
        return "Sai mật khẩu";
      }
    }
  }

  initHome() async{
    await getDatabase();
    String? value = await sharedPref.read(key: "user");
    if(value!.isNotEmpty){
      Navigator.pushNamed(context, '/home');
    }
  }


  Widget buildLoadingScreen(BuildContext context){
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          backgroundColor: Colors.blue,
        ),
        SizedBox(
          height: 10,
        ),
        Text("Loading...", style: TextStyle(
            fontSize: 25,
            color: Colors.blue
        ),)
      ],
    );
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
              Text('Connecting to Home...',style: TextStyle(
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
