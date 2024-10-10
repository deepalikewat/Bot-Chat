import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}
class _ConversationPageState extends State<ConversationPage> {
  TextEditingController _messageController = TextEditingController();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<Map<String, dynamic>> messages = [];
  final rdata = '''{
  "restaurant": [
    {
      "bot": "Hello",
      "human": "Good afternoon"
    },
    {
      "bot": "Welcome to the restaurant",
      "human": "Thank you"
    },
    {
      "bot": "What would you like?",
      "human": "I would like a tea"
    },
    {
      "bot": "Would you like some food?",
      "human": "A fish please"
    },
    {
      "bot": "Anything else?",
      "human": "Yes, with grilled vegetables"
    },
    {
      "bot": "Would you like some water?",
      "human": "Yes, please"
    }
  ]
}''';
  void _fetchMessages() async {
    final data = jsonDecode(rdata);

    List<dynamic> vchats = data["restaurant"] ?? [];

    List<Map<String, dynamic>> tmpmsg = [];

    vchats.forEach((chatdata) {
      tmpmsg.add({"text": chatdata["bot"], "isSentByMe": false});
      tmpmsg.add({"text": chatdata["human"], "isSentByMe": true});
    });

    setState(() {
      messages = tmpmsg;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }


  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _messageController.text =
          _lastWords;
    });
  }

  void _sendMessage() {
    setState(() {
      if (_messageController.text.isNotEmpty) {
        messages.add({'text': _messageController.text, 'isSentByMe': true});
        _messageController.clear();
      }
    });
  }

  Widget _buildMessageItem(String text, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            'Chats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(
                  messages[index]['text'],
                  messages[index]['isSentByMe'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.black),
                  onPressed: _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ConversationPage()));
}
