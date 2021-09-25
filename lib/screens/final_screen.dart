import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_envi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:convert';
import 'package:project_envi/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


String capitalize(String s) {
  var li = s.split(" ");
  String r = "";
  for(int i=0; i<li.length; i++){
    r += "${li[i][0].toUpperCase()}${li[i].substring(1).toLowerCase()} ";
  }
  return r;
}


class FinalScreen extends StatefulWidget {
  const FinalScreen({Key? key}) : super(key: key);

  @override
  _FinalScreenState createState() => _FinalScreenState();
}



class _FinalScreenState extends State<FinalScreen> {
  final ImagePicker _picker = ImagePicker();
  var startPoint;
  var endPoint;
  XFile? img;
  String? origin ,destination ;
  var pos, duration , distance;
  Future<bool>? _data;
  late String uniqueId;

  @override
  void initState(){
    super.initState();
    _data = getData();
  }



  Future<bool> getData() async {
    img = await _picker.pickImage(source: ImageSource.gallery);
    if(img == null){
      Navigator.of(context).pop();
      return false;
    }
    else {
      RegExp regExp = RegExp(
        r"No:[0-9 ]",
        caseSensitive: false,
        multiLine: false,
      );

      final inputImage = InputImage.fromFilePath(img!.path);
      final textDetector = GoogleMlKit.vision.textDetector();
      final RecognisedText recognisedText =
      await textDetector.processImage(inputImage);
      List<String> arr = [];
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            print(element.text);
            if(regExp.hasMatch(element.text)){
              uniqueId = element.text.substring(3);
            }
            arr.add(element.text);
          }
        }
      }
      int i = 0;
      while (i < arr.length) {
        if (arr[i]
            .split(":")
            .length == 3) {
          int j = i + 1;
          while (j < arr.length && arr[j] != "to") {
            j += 1;
          }
          startPoint = arr.sublist(i + 1, j).join("+");
          endPoint = arr.sublist(j + 1, j + 3).join("+");
          break;
        }
        i += 1;
      }
      print(startPoint);
      print(endPoint);

      if(startPoint==null || endPoint == null){
        print("ibnfs");
        alertDialog(context,'Invalid Ticket');
        return false;
      }else{
        origin  = await getGeocode(startPoint);
        destination = await getGeocode(endPoint);
        await getDistance();
        setState((){
        });
      }

      return true;
    }
  }


  Future<String> getGeocode(String location) async {
    final response = await http.get(
      Uri.parse(
          "https://geocode.search.hereapi.com/v1/geocode?apiKey=${ENTER API KEY HERE}&q=$location+Pune"),
    );
    final body = json.decode(response.body);
    pos = body["items"][0]["position"];
    return ("${pos["lat"]},${pos["lng"]}");
  }

  Future<Map<String,dynamic>> getDistance() async {
    final response = await http.get(Uri.parse(
      "https://router.hereapi.com/v8/routes?&apiKey=${ENTER API KEY HERE}&transportMode=bus&origin=$origin&destination=$destination&return=summary",
    ));
    final body = json.decode(response.body);
    duration = body["routes"][0]["sections"][0]["summary"]["duration"];
    distance = body["routes"][0]["sections"][0]["summary"]["length"] / 1000;
    print("dur $duration & dist $distance");
    return {
      "duration": duration,
      "distance": distance,
    };
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _data,
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
            if(!snapshot.hasData || img == null || snapshot.data==false){
                return Lottie.asset(
                  'assets/lottie/loading.json',
                  repeat: true,
                  width: _size.width*0.6,
                );
            }
            else{
              final String originStr = capitalize(startPoint.replaceAll("+", " ")),
                  destinationStr = capitalize(endPoint.replaceAll("+", " "));
              final Duration dur = Duration(seconds: duration?? 0);
              return Consumer(
                  builder: (context, watch, child) {
                  final instProvider = watch(firebaseInst);
                  final leaderProvider = watch(leaderCollection);
                  final userP = watch(userProvider);
                  final coinsEarned = (dur.inMinutes)*distance/100;
                  var isDuplicate = false;

                  instProvider.collection('tickets').where('id', isEqualTo: uniqueId).get().then((value){
                    if(value.docs.isEmpty){
                      instProvider.collection('tickets').add(
                          {
                            'id': uniqueId,
                          });
                      leaderProvider
                          .doc(watch(docIdProvider))
                          .update({
                        "score": userP.state['score'] + distance,
                        "coins": userP.state['coins'] + coinsEarned,
                      });
                      print("assad");

                    }
                    else{
                      print("dupli");
                      isDuplicate = true;
                      alertDialog(context,'Ticket already Redeemed');
                      // return const SizedBox(width: 100,height: 100,);
                    }

                  });
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex:28,
                        child: Container(
                          width: _size.width*0.85,
                          height: _size.height*0.9,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius:BorderRadius.all(
                                Radius.circular(_size.width/10)
                            ),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(0,6),
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 10
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                flex: 10,
                                child: Container(
                                  width: _size.width*0.85,
                                  margin: EdgeInsets.only(top: _size.width*0.05),
                                  decoration: BoxDecoration(
                                    color: primaryC,
                                    borderRadius: BorderRadius.all(Radius.circular(_size.width/15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Spacer(
                                        flex: 2,
                                      ),
                                      const Expanded(
                                        flex: 9,
                                        child: Text(
                                          'Coins\nEarned',
                                          style: TextStyle(
                                            fontSize: 25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const Spacer(
                                        flex: 1,
                                      ),
                                      Expanded(
                                        flex:6,
                                        child: Text(
                                          coinsEarned.toStringAsPrecision(3),
                                          style: const TextStyle(
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: FaIcon(
                                          FontAwesomeIcons.leaf,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      const Spacer(
                                        flex: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex:55,
                                child: Container(
                                  width: _size.width*0.85,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:BorderRadius.all(
                                        Radius.circular(_size.width/10)
                                    ),
                                  ),
                                  child: (originStr == null || destinationStr == null)?
                                  const Text(
                                    "Error! Ticket\nNot Recognised",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      :Column(
                                    children: [
                                      Container(
                                        width:_size.width*0.85,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:BorderRadius.all(
                                              Radius.circular(_size.width/10)
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(_size.width/10),
                                          child: img!=null ? Image.file(
                                            File(img!.path),
                                            width: _size.width*0.85,
                                          ) : Container(),
                                        ),
                                      ),

                                      const Spacer(
                                        flex: 2,
                                      ),
                                      const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Origin:',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          originStr,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Destination:',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          destinationStr,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const Divider(
                                        thickness: 3,
                                        indent: 30,
                                        endIndent: 30,
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'Distance\n${distance.toStringAsPrecision(3)} km',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'Time\n${dur.inMinutes} min',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 1,),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: ((){
                            final index = context.read(indexProvider);
                            index.state = 2;
                            Navigator.pop(context);
                          }),
                          child: Container(
                            width: _size.width*0.85,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:BorderRadius.all(
                                  Radius.circular(_size.width/10)
                              ),
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0,6),
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 10
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Open Leaderboard",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1,),
                    ],
                  );
                }
              );
            }
          },
        ),
      ),
    );
  }

  void alertDialog(BuildContext context,String msg) => showDialog(
    barrierColor: Colors.white,
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text(
        'Error!',
        style: TextStyle(
          fontSize: 25,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        msg,
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold
        ),
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      actions: <Widget>[
        TextButton(
          child: const Center(child: Text(
            'Continue',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

