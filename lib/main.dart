
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/Views/AddTopicFolder.dart';
import 'package:finalapp/Views/AllTopic.dart';
import 'package:finalapp/Views/CreateStudySet.dart';
import 'package:finalapp/Views/CreateTopic.dart';
import 'package:finalapp/Views/DetailFolder.dart';
import 'package:finalapp/Views/DetailTopic.dart';
import 'package:finalapp/Views/FolderSet.dart';
import 'package:finalapp/Views/ForgotPassword.dart';
import 'package:finalapp/Views/Leaderboard.dart';
import 'package:finalapp/Views/LearningFlashCard.dart';
import 'package:finalapp/Views/Library.dart';
import 'package:finalapp/Views/MultipleChoice.dart';
import 'package:finalapp/Views/ResultFlashCard.dart';
import 'package:finalapp/Views/ResultTypeWord.dart';
import 'package:finalapp/Views/SaveAndEdit.dart';
import 'package:finalapp/Views/SettingTopic.dart';
import 'package:finalapp/Views/Signup.dart';
import 'package:finalapp/Views/StudySet.dart';
import 'package:finalapp/Views/TypeWord.dart';
import 'package:finalapp/providers/counter_provider.dart';
import 'package:finalapp/providers/multiple_choice.dart';
import 'package:finalapp/providers/type_words.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Views/Home.dart';
import 'Views/Login.dart';
import 'Views/ResultMultipleChoice.dart';
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,name:'QuizletApp');
  await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>CounterProvider()),
      ChangeNotifierProvider(create: (context)=>TypeWordProvider()),
      ChangeNotifierProvider(create: (context)=>MultipleChoiceProvider())
    ],
    child:MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateRoute: (settings){
      var args=settings.arguments;
      switch(settings.name) {
        case '/':
          return MaterialPageRoute(builder: (ctx) => LogIn());
        case '/home':
          return MaterialPageRoute(builder: (ctx) => Home());
        case '/allTopic':
          return MaterialPageRoute(builder: (ctx) => AllTopic());
        case '/signup':
          return MaterialPageRoute(builder: (ctx) => SignUp());
        case '/saveAndEdit':
          return MaterialPageRoute(builder: (ctx) => SaveAndEdit(topic:args));
        case '/forgotPassword':
          return MaterialPageRoute(builder: (ctx) => ForgotPassword());
        case '/library':
          return MaterialPageRoute(builder: (ctx) => Library());
        case '/topics':
          return MaterialPageRoute(builder: (ctx) => StudySet());
        case '/folders':
          return MaterialPageRoute(builder: (ctx) => FolderSet());
        case '/detailsFolder':
          return MaterialPageRoute(builder: (ctx) => DetailFolder(folder: args,));
        case '/settingTopic':
          return MaterialPageRoute(builder: (ctx) => const SettingTopic());
        case '/createTopic':
          return MaterialPageRoute(builder: (ctx) => CreateTopic(topic:args));
        case '/createStudySet':
          return MaterialPageRoute(builder: (ctx) => CreateStudySet(folder: args,));
        case '/detailTopic':
          return MaterialPageRoute(builder: (ctx)=>DetailTopic(topic:args));
        case '/learningFlashCard':
          return MaterialPageRoute(builder: (ctx)=>LearningFlashCard(topic: args,));
        case '/multipleChoice':
          return MaterialPageRoute(builder: (ctx)=>MultipleChoice(topic: args,));
        case '/resultMultipleChoice':
          return MaterialPageRoute(builder: (ctx)=>ResultMultipleChoice(topic:args));
        case '/resultFlashCard':
          return MaterialPageRoute(builder: (ctx)=>ResultFlashCard(topic:args));
        case '/resultTypeWord':
          return MaterialPageRoute(builder: (ctx)=>ResultTypeWord(topic:args));
        case '/typeWord':
          return MaterialPageRoute(builder: (ctx) => TypeWord(topic: args,));
        case '/leaderBoard':
          return MaterialPageRoute(builder: (ctx)=>LeaderBoard(list: args,));
        case '/addTopicFolder':
          return MaterialPageRoute(builder: (ctx)=>AddTopicFolder(topic: args,));
      }
    },
    theme: ThemeData(
      dialogBackgroundColor: Colors.white,
      cardColor: Colors.white,
      tabBarTheme: const TabBarTheme(
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          indicatorColor: Colors.black
      ),
      dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: Colors.white,
      ),
      dividerColor: Colors.black,
      ),
    ),
  )
  );
}


