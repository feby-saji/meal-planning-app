import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/models/hive_models/family.dart';
import 'package:meal_planning/models/hive_models/shoppinglist_item.dart';
import 'package:meal_planning/screens/shopping_list/bloc/shopping_list_bloc.dart';

class FireStoreFunctions {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference familyCollection =
      FirebaseFirestore.instance.collection('family');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference shopppingListCollection =
      FirebaseFirestore.instance.collection('shopping_list');
  final db = FirebaseFirestore.instance;

// user functions
  Future<String> checkIfUserInFam() async {
    print('//checkIfUserInFam  usr uid $userUid');
    final docSnapshot = await usersCollection.doc(userUid).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()! as Map;
      return data['familyId'] as String;
    } else {
      print("//checkIfUserInFam Document does not exist ");
      return "";
    }
  }

  createUser(User user) async {
    await usersCollection.doc(userUid).set({
      'username': user.displayName,
      'email': user.email,
      'familyId': '',
    });
  }

// family functions
  createFamily() async {
    String? userName = FirebaseAuth.instance.currentUser!.displayName;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentReference docRef = await familyCollection.add({
        'creator': uid,
        'familyId': '',
        'members': [uid],
        'createdOn': Timestamp.now(),
        'shopping list': {},
      });
      CollectionReference shoppingListRef = docRef.collection('shopping_list');
      await shoppingListRef.doc('shopping list').set({'items': {}});

      await docRef.update({'familyId': docRef.id});
      // update in user doc
      await usersCollection.doc(userUid).update({'familyId': docRef.id});
      // update in hive
      Family familyModel =
          Family(familyId: docRef.id, creator: uid, members: [userUid]);
      await HiveDb.updateFamily(familyModel);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> familyExist(familyId) async {
    DocumentSnapshot docSnap = await familyCollection.doc(familyId).get();
    if (docSnap.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future joinFamily(familyId) async {
// add family id to user doc
    await usersCollection.doc(userUid).update({'familyId': familyId});

    // add user to the family
    await familyCollection.doc(familyId).update({
      'members': FieldValue.arrayUnion([userUid])
    });
    // get family details from firestore
    DocumentSnapshot docSnap = await familyCollection.doc(familyId).get();
    final data = docSnap.data() as Map;

    // save fam details in hive
    Family family = Family(
        familyId: data['familyId'],
        creator: data['creator'],
        members: data['members']);
    await HiveDb.updateFamily(family);
    print('//joining  current members are $data[members]');
  }

  Future<Family> fetchFamilyDetails() async {
    try {
      // get family id
      DocumentSnapshot docSnapshot = await usersCollection.doc(userUid).get();
      String familyId = docSnapshot.get('familyId');
// get familt details
      DocumentSnapshot fdocSnapshot =
          await familyCollection.doc(familyId).get();
      Family family = Family(
        familyId: fdocSnapshot.get('familyId'),
        creator: fdocSnapshot.get('creator'),
        members: fdocSnapshot.get('members'),
      );
      await HiveDb.updateFamily(family);
      return family;
    } catch (e) {
      print('Error getting familyId: $e');
      return Family(familyId: 'err', creator: '', members: []);
    }
  }

  // shopping list functions
 Future<void> writeShoppingListItems(Map<String, dynamic> mapOfItems) async {
    print('//writeShoppingListItems writing items to firestore');

    // Get family id
    DocumentSnapshot docSnapshot = await usersCollection.doc(userUid).get();
    String familyId = docSnapshot.get('familyId');

    // Reference to the shopping list document
    DocumentReference shoppingListRef = familyCollection
        .doc(familyId)
        .collection('shopping_list')
        .doc('shopping list');

    // Check if the document exists to decide whether to set or update
    DocumentSnapshot docSnap = await shoppingListRef.get();
    if (docSnap.exists && docSnap.data() != null) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic> existingData = docSnap.data() as Map<String, dynamic>;
        Map<String, dynamic> existingItems = existingData['items'] ?? {};

        // Merge the new items into the existing 'items' map
        existingItems.addAll(mapOfItems);

        // Update the 'items' field with merged data
        await shoppingListRef.set(
            {'items': existingItems},
            SetOptions(merge: true), // Merge option to update existing data
        );
    } else {
        // If document does not exist, create it with the new 'items' map
        await shoppingListRef.set({'items': mapOfItems});
    }
}



  Future<List<ShopingListItem>?> readShoppingListItems() async {
    print('//readShoppingListItems reading items from firestore');

    // get family id
    DocumentSnapshot docSnapshot = await usersCollection.doc(userUid).get();
    String familyId = docSnapshot.get('familyId');

    DocumentSnapshot docSnap = await familyCollection
        .doc(familyId)
        .collection('shopping_list')
        .doc('shopping list')
        .get();

    if (docSnap.exists && docSnap.data() != null) {

      List<ShopingListItem> shoppingListItems = [];
      Map<String, dynamic> shoppingListData =
          docSnap.data() as Map<String, dynamic>;
      Map<String, dynamic> itemsMap =
          shoppingListData['items'] as Map<String, dynamic>;
      if (itemsMap.isNotEmpty) {
        itemsMap.forEach((itemName, data) {
          shoppingListItems
              .add(ShopingListItem(name: itemName, quantity: data['quantity']));
        });
      } else {
        return null;
      }
      return shoppingListItems;
    }
    return null;
  }

  deleteShoppingListItems() async{

  }
}
