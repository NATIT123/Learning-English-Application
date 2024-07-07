
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';


import '../../dto/UserDetail.dart';
import 'UserDatabaseRef.dart';
import 'SharedPref.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
final UserDatabaseRef databaseRef = UserDatabaseRef();
final SharedPrefService sharedPref = SharedPrefService();

class Utils{
  Future<String> uploadImageToStorage(String childName, Uint8List file) async{
    Reference ref = _storage.ref().child(childName).child('id');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required name,
    required email,
    required Uint8List file,
    required createdAt,
    required id}) async{
    String resp = "Có lỗi xảy ra!";
    try{
      String image = await uploadImageToStorage("ProfileImage", file);
      UserDetail tmp = UserDetail(fullName: name, userName: name, email: email, imgPath: image, id: id);
      databaseRef.updateUserDetail(id, tmp);
      resp = "Thành công!";
    }catch(err){
      resp = err.toString();
    }
    return resp;
  }
}

pickImage(ImageSource source) async{
  final ImagePicker _imagePicker = ImagePicker();
  XFile? file = await _imagePicker.pickImage(source: source);
  if(file != null){
    return await file.readAsBytes();
  }
}