import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:project_envi/providers.dart';
import 'package:project_envi/colors.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class Dashboard extends ConsumerWidget {

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: StreamBuilder(
        stream: watch(leaderCollection).doc(watch(docIdProvider)).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData) {
          return Container();
          } else {
            final userP = snapshot.data!.data();
            userProvider = StateProvider<Map<String,dynamic>>((ref) => userP);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: Shimmer(
                    duration: const Duration(seconds: 1), //Default value
                    interval: const Duration(seconds: 1),
                    child: Container(
                      width: _size.width * 0.65,
                      margin: EdgeInsets.only(top: _size.width * 0.05),
                      decoration: BoxDecoration(
                        color: primaryC,
                        borderRadius: BorderRadius.all(Radius.circular(
                            _size.width / 15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 2,
                          ),
                          const Expanded(
                            flex: 6,
                            child: Text(
                              'Total\nCoins',
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
                            flex: 8,
                            child: Text(
                              userP['coins'].toStringAsPrecision(4),
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
                ),
                const Spacer(flex: 2,),
                const Expanded(
                  flex: 4,
                  child: Text(
                    'Prevented CO2 emissions up to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontFeatures: [
                        FontFeature.subscripts(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child:
                  Text(
                    "${(0.2113 * userP['score']).toStringAsPrecision(
                        4)} kg",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Lottie.asset(
                    'assets/lottie/23968-save-environment.json',
                    repeat: watch(animNotifier),
                    reverse: true,
                  ),
                ),
                const Divider(
                  thickness: 3,
                  indent: 30,
                  endIndent: 30,
                ),
                const Spacer(flex: 1,),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Bus\n${userP['score'].toStringAsPrecision(3)}km',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 27,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'Train\n59km',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 1,),
              ],
            );
          }
        }
      ),
    );
  }
}
