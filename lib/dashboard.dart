import 'package:sivi/conversation.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SharedPreferences? sp;

  List<Map<String, String>> chats = [];

  Future<void> goChat(String titlex, {String predata = ""}) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationPage(
            titlex: titlex,
            savedData: predata,
          ),
        )).then((u) {
      initx();
    });
  }

  Future<void> initx() async {
    chats = [];

    sp = await SharedPreferences.getInstance();

    final ids = (sp?.getStringList("ids") ?? []);

    ids.forEach((element) {
      final name = sp?.getStringList(element);
      DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(element));
      chats.add({'title': "${name?[0]}", 'message': "$date", "id": element});
    });
    chats = chats.reversed.toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initx();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                sp?.clear();
                chats.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clean_hands),
              color: Colors.white,
            ),
          ],
          leadingWidth: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.indigo,
          elevation: 4.0,
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) => Container(
            color: const Color.fromARGB(255, 195, 203, 207),
            height: 1,
          ),
          itemCount: chats.length,
          // reverse: true,
          itemBuilder: (context, index) {
            return ChatItem(
              idx: chats[index]['id']!,
              index: index,
              title: chats[index]['title']!,
              message: chats[index]['message']!,
            );
          },
        ),
        floatingActionButton: SpeedDialFabWidget(secondaryIconsText: const [
          "Restaurant",
          "Vehicle",
          "Hotel",
          "Support",
          "Flight"
        ], secondaryIconsList: const [
          Icons.restaurant_rounded,
          Icons.car_rental,
          Icons.hotel,
          Icons.support_agent,
          Icons.flight
        ], secondaryIconsOnPress: [
          () {
            goChat("Restaurant");
          },
          () {
            goChat("Vehicle");
          },
          () {
            goChat("Hotel");
          },
          () {
            goChat("Support");
          },
          () {
            goChat("Flight");
          }
        ]));
  }
}

class ChatItem extends StatelessWidget {
  final String title;
  final String message;
  final int index;
  final String idx;

  ChatItem(
      {required this.title,
      required this.message,
      required this.index,
      required this.idx});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: const Color(0xff1f1c39),
      leading: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 80, 101, 223),
        child: Text(
          "$index",
          style: const TextStyle(fontFamily: "impact", color: Colors.white),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.indigo, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                titlex: title,
                savedData: idx,
              ),
            ));
      },
    );
  }
}
