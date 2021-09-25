import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final docIdProvider = Provider<String>((ref)=> "9IxLuoBAEYtcU1yCmMiJ");
final indexProvider = StateProvider<int>((ref) => 0);
final imageProvider = StateProvider<XFile?>((ref) => null);


late StateProvider<Map<String,dynamic>> userProvider;
final firebaseInst =  Provider<FirebaseFirestore>((ref)=> FirebaseFirestore.instance);
final leaderCollection =  Provider<CollectionReference>((ref)=> ref.watch(firebaseInst).collection("leaderboard"));

final firebaseProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(leaderCollection)
      .orderBy("score", descending: true)
      .snapshots();
}
);


final animNotifier = StateNotifierProvider<LottieController,bool>((ref) => LottieController());

class LottieController extends StateNotifier<bool>{
  LottieController() : super(true){
    start();
  }

  void start(){
    state = true;
    Future.delayed(const Duration(seconds: 1),
      (){
        stop();

      }
    );
  }

  void stop(){
    state = false;
  }
}
