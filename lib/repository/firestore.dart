import 'package:cloud_firestore/cloud_firestore.dart';

class FireStore {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference familyCollection =
      FirebaseFirestore.instance.collection('family');

  createFamily() async {
    familyCollection.add({
      
    });
  }
}
