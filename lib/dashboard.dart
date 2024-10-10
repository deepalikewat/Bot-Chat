import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, String>> chats = [
    {'title': 'Chat 1', 'message': 'Hello, this is chat 1'},
    {'title': 'Chat 2', 'message': 'Hello, this is chat 2'},
  ];

  void _addChat() {
    setState(() {
      int nextChatNum = chats.length + 1;
      chats.add({'title': 'Chat $nextChatNum', 'message': 'Hello, this is chat $nextChatNum'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 4.0,
        actions: [
        
          PopupMenuButton<String>(
              icon: const Icon(
            Icons.menu, 
            color: Colors.white,
            size: 30.0, 
          ),
            onSelected: (String value) {},
            itemBuilder: (BuildContext context) {
              return {'Settings', 'Delete', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ChatItem(
            title: chats[index]['title']!,
            message: chats[index]['message']!,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChat,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.chat,
        color: Colors.white,
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String title;
  final String message;

  ChatItem({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(title.substring(4)),
        backgroundColor: Colors.blue,
      ),
      title: Text(title),
      subtitle: Text(message),
      onTap: () {},
    );
  }
}
