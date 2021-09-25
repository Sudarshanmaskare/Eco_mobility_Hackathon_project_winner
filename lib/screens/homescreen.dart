import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_envi/colors.dart';
import 'package:project_envi/providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_envi/screens/dashboard_screen.dart';
import 'package:project_envi/screens/leaderboard_screen.dart';
import 'package:project_envi/screens/select_ticket.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Size _size;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
          final provider = watch(indexProvider);
          final providedHeight = provider.state == 0? 0.75:0.2;

          return Stack(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticInOut,
                    width: _size.width,
                    height: providedHeight * _size.height,

                    decoration: BoxDecoration(
                      color: primaryC,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(_size.width*(0.25))
                        )
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticInOut,
                    color: primaryC,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticInOut,
                      width: _size.width,
                      height: (1 - providedHeight) * _size.height,

                      decoration: BoxDecoration(
                          color: secondaryC,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(_size.width*(0.25))
                          )
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                width: _size.width,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildBottomButton(
                        icon: FontAwesomeIcons.chartPie,
                        focus: provider.state == 0,
                        index: 0,
                    ),
                    buildBottomButton(
                        icon: FontAwesomeIcons.ticketAlt,
                        focus: provider.state == 1,
                        index: 1,
                    ),
                    buildBottomButton(icon: FontAwesomeIcons.trophy,
                        focus: provider.state == 2,
                        index: 2,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: _size.height*0.05,
                left: _size.width*0.1,
                child:IndexedStack(
                  index: provider.state,
                  children: [
                    buildPageContainer(
                      title: "Dashboard",
                      child: Dashboard(),
                    ),
                    buildPageContainer(
                      title: "Verify Ticket",
                      child: SelectTicket(),
                    ),
                    buildPageContainer(
                      title: "Leaderboard",
                      child: Leaderboard(),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                // height: _size.height/8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Icon(
                      Icons.drag_handle_rounded,
                      color: textC,
                      size: _size.width/10,
                    ),
                    CircleAvatar(
                      radius: _size.width/18,
                    ),
                  ],
                ),
              ),

            ],
          );
        },
      ),
    );
  }

  Container buildPageContainer({required Widget child,required String title }) {
    return Container(
                    width: _size.width*0.8,
                    height: _size.height*0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Center(
                          child: Container(
                            width: (title == "Leaderboard") ? double.infinity : _size.width*0.75,
                            height: _size.height*0.65,
                            decoration:(title == "Leaderboard") ? null : BoxDecoration(
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
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  );
  }

  Container buildBottomButton({required IconData icon,  required int index, required bool focus}) {
    return Container(
            color:secondaryC,
            width: _size.width/6.5,
            height: _size.height*0.07,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    final p = context.read(indexProvider);
                    p.state = index;
                    print(p.state);
                    if(p.state==0) {
                      context.read(animNotifier.notifier).start();
                    } else {
                      context.read(animNotifier.notifier).stop();
                    }

                  },
                  child: FaIcon(
                    icon,
                    color: textC,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.decelerate,
                  height: focus?_size.height*0.01:0,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                      color: textC,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10))
                  ),
                )
              ],
            ),
          );
  }
}
