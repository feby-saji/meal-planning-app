import 'package:cloud_firestore/cloud_firestore.dart';

class Family {
  String familyId;
  String creator;
  List members;
  Timestamp createdOn;

  Family({
    required this.familyId,
    required this.creator,
    required this.members,
    required this.createdOn,
  });
}
