import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:project_envi/providers.dart';
import 'package:project_envi/screens/final_screen.dart';

class SelectTicket extends ConsumerWidget {
  SelectTicket({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _size = MediaQuery.of(context).size;
    final provider = watch(indexProvider);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 5,
              child:
              GestureDetector(
                onTap: (() async {
                  //   Navigator.of(context).push(MaterialPageRoute(builder: (context)
                  await Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration:
                          Duration(milliseconds: 250),
                          reverseTransitionDuration:
                          Duration(milliseconds: 150),
                          transitionsBuilder:
                              (BuildContext context,
                              Animation<double>
                              animation,
                              Animation<double>
                              secAnimation,
                              Widget child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          pageBuilder: (BuildContext
                          context,
                              Animation<double> animation,
                              Animation<double> secAnimation) {
                            return const FinalScreen();
                          }));
                }),
                child: Lottie.asset(
                    'assets/lottie/bus-ticket.json',
                    repeat: provider.state == 1,
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Text(
                'Bus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(flex: 1,),
            const Divider(
              thickness: 3,
              indent: 30,
              endIndent: 30,
            ),
            Expanded(
              flex: 5,
              child:
              Lottie.asset(
                  'assets/lottie/train-animation.json',
                  repeat: provider.state == 1,
              ),
            ),
            const Expanded(
              flex: 1,
              child: Text(
                'Train',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}