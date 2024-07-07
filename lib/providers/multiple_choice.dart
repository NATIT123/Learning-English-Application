import 'package:flutter/widgets.dart';

class MultipleChoiceProvider extends ChangeNotifier{
  int falseValue;
  int trueValue;
  int progressValue;




  MultipleChoiceProvider({
    this.progressValue=0,
    this.falseValue=0,
    this.trueValue=0
  });

  void increaseProgressValue(){
    progressValue++;
    notifyListeners();
  }

  void decreaseProgressValue(){
    progressValue--;
    notifyListeners();
  }

  void increaseFalseValue(){
    falseValue++;
    notifyListeners();
  }

  void decreaseFalseValue(){
    falseValue--;
    notifyListeners();
  }

  void increaseTrueValue(){
    trueValue++;
    notifyListeners();
  }
}