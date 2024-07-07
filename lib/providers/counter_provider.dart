import 'package:flutter/widgets.dart';

class CounterProvider extends ChangeNotifier{
  int neValue;
  int poValue;
  int progressValue;

  bool shuffle;

  bool autoSpeak;

  bool position;

  bool autoSlide;

  bool modeStudy;


  CounterProvider({
    this.neValue=0,
    this.poValue=0,
    this.progressValue=0,
    this.shuffle=false,
    this.autoSpeak=false,
    this.position=false,
    this.autoSlide=false,
    this.modeStudy=false,
});
  void incrementNeValue(){
    neValue++;
    notifyListeners();
  }

  void decrementNeValue(){
    neValue--;
    notifyListeners();
  }

  void incrementPoValue(){
    poValue++;
    notifyListeners();
  }

  void decrementPoValue(){
    poValue--;
    notifyListeners();
  }


  void increaseProgress(){
    progressValue++;
    notifyListeners();
  }

  void decreaseProgress(){
    progressValue--;
    notifyListeners();
  }


  void changeShuffle(){
    shuffle=!shuffle;
    notifyListeners();
  }

  void changeAutoSpeak(){
    autoSpeak=!autoSpeak;
    notifyListeners();
  }

  void changeProgress(int value){
    progressValue=value;
    notifyListeners();
  }

  void changePosition(){
    position=!position;
    notifyListeners();
  }

  void changeAutoSlide(){
    autoSlide=!autoSlide;
    notifyListeners();
  }

  void changeModeStudy(){
    modeStudy=!modeStudy;
  }

}