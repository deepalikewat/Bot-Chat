import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_diff_text/pretty_diff_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationPage extends StatefulWidget {
  final String titlex;
  final String savedData;

  const ConversationPage(
      {super.key, required this.titlex, this.savedData = ""});
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TextEditingController _messageController = TextEditingController();

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  List<dynamic> messages = [];

  List<dynamic> tmpmsg = [];

  int currentIndex = 0;

//   final rdata = '''[
//     {
//       "bot": "Hello",
//       "human": "Good afternoon"
//     },
//     {
//       "bot": "Welcome to the restaurant",
//       "human": "Thank you"
//     },
//     {
//       "bot": "What would you like?",
//       "human": "I would like a tea"
//     },
//     {
//       "bot": "Would you like some food?",
//       "human": "A fish please"
//     },
//     {
//       "bot": "Anything else?",
//       "human": "Yes, with grilled vegetables"
//     },
//     {
//       "bot": "Would you like some water?",
//       "human": "Yes, please"
//     }
//   ]
// ''';
  bool loading = true;
  Future<void> _fetchMessages() async {
    if (widget.savedData.length > 3) {
      loadData().then((b) {
        setState(() {
          loading = false;
        });
      });
    } else {
      print(
          "http://my-json-server.typicode.com/deepalikewat/demoapi1/${widget.titlex}");
      final rsdata = await http.get(Uri.parse(
          "http://my-json-server.typicode.com/deepalikewat/demoapi1/${widget.titlex}"));

      final data = jsonDecode(rsdata.body);
      print(data);

      List<dynamic> vchats = data ?? [];

      vchats.forEach((chatdata) {
        tmpmsg.add({"text": chatdata["bot"], "isSentByMe": false});
        tmpmsg.add({"text": chatdata["human"], "isSentByMe": true});
      });

      setState(() {
        loading = false;

        if (tmpmsg.isNotEmpty) {
          messages.add(tmpmsg[0]);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchMessages();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    // if (_speechEnabled) {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
    // }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      // _messageController.text = _lastWords;
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
          color: isSentByMe ? const Color(0xff2b2251) : const Color(0xff6f61e8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> savedata() async {
    final sp = await SharedPreferences.getInstance();

    if (widget.savedData.length > 3) {
      final tmpDatList = sp.getStringList(widget.savedData) ?? [];

      tmpDatList[2] = jsonEncode(messages);

      await sp.setStringList(widget.savedData, tmpDatList);
    } else {
      final uniqId = DateTime.now().millisecondsSinceEpoch.toString();

      print(uniqId);
      await sp
          .setStringList("ids", [...(sp.getStringList("ids") ?? []), uniqId]);

      await sp.setStringList(
          uniqId, [widget.titlex, jsonEncode(tmpmsg), jsonEncode(messages)]);
    }

    if (!mounted) {
      return;
    }

await showDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Success!'),
        content: const Text('Your data has been successfully saved.'),
        actions:[
         
          TextButton(
            onPressed: () {
                Navigator.pop(context); //close Dialog
            },
            child: const Text('OK'),
          )
        ],
      );
    });






    Navigator.pop(context);
  }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();

    if (widget.savedData.length > 3) {
      final tmpDatList = sp.getStringList(widget.savedData) ?? [];

      print(tmpDatList[1]);

      tmpmsg = jsonDecode(tmpDatList[1]);
      messages = jsonDecode(tmpDatList[2]);
      currentIndex = messages.length - 1;
    }
  }

  Future<void> finshDilog() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: const Color(0xfff8f8f8),
            actionsAlignment: MainAxisAlignment.spaceAround,
            contentPadding: const EdgeInsets.all(20),
            title: const Icon(
              Icons.done,
              color: Color(0xff6f61e8),
              size: 50,
            ),
            actions: [
              FilledButton(
                  onPressed: () {
                    setState(() {
                      loading = false;
                    });
                  },
                  child: const Text("Home")),
              FilledButton(
                  onPressed: () {
                    //
                    savedata();
                    // Navigator.pop(context);
                  },
                  child: const Text("Save"))
            ],
            content: const Text(
              "You Have Compeleted",
              textAlign: TextAlign.center,
            )));
  }

  Future<void> checktext() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: const Color(0xfff8f8f8),
          actionsAlignment: MainAxisAlignment.spaceAround,
          contentPadding: const EdgeInsets.all(20),
          title: const Icon(
            Icons.emoji_events,
            color: Color(0xff6f61e8),
            size: 50,
          ),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    recordState = 0;
                  });
                },
                child: const Text("Restart")),
            FilledButton(
                onPressed: () {
                  if (currentIndex + 2 < tmpmsg.length - 1) {
                    setState(() {
                      messages.add({"text": _lastWords, "isSentByMe": true});

                      messages.add(tmpmsg[currentIndex + 2]);

                      currentIndex += 2;
                      // _lastWords = tmpmsg[currentIndex + 1]["text"];
                    });
                  } else if (currentIndex < tmpmsg.length - 1) {
                    setState(() {
                      messages.add({"text": _lastWords, "isSentByMe": true});

                      _lastWords = "";
                    });
                    finshDilog();
                  }

                  Navigator.pop(context);
                },
                child: const Text("Skip"))
          ],
          content: PrettyDiffText(
              textAlign: TextAlign.center,
              oldText: _lastWords.toLowerCase(),
              newText: tmpmsg[currentIndex + 1]["text"].toLowerCase() .replaceAll(RegExp(r'[^a-z ]'), '')),
      ));
  }

  int recordState = 0;

  TextEditingController testx = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff25204d),
      appBar: AppBar(
        backgroundColor: const Color(0xff25204d),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              label: const Text("back"),
              icon: const Icon(Icons.keyboard_backspace),
            ),
            Text(
              "${widget.titlex}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            TextButton.icon(
              onPressed: () {
                // savedata();
              },
              label: const Text("Save"),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.save),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xff1f1c39),
              boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 1)],
              borderRadius: BorderRadius.circular(20)),
          child: loading
              ? Center(
                  child: Image.asset(
                    "images/loading.gif",
                    width: 40,
                  ),
                )
              : Column(
                  children: [
                   
                   
                   Visibility(
                    visible: recordState==1,
                     child: Container(
                      padding: const EdgeInsets.all(5),
                     
                     child: Text(_lastWords,style: const TextStyle(
                       color: Colors.white
                     ),),
                     ),
                   )
,                    
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
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff29244d),
                          borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.only(
                          left: 15, right: 5, top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            "${tmpmsg[currentIndex + 1]["text"] ?? ""}",
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                          )
                              ),
                          switch (recordState) {
                            0 => IconButton(
                                icon:
                                    const Icon(Icons.mic, color: Colors.white),
                                onPressed: () {
                                  _startListening();
                                  setState(() {
                                    recordState = 1;
                                  });
                                }),
                            1 => IconButton(
                                icon: const Icon(
                                  Icons.stop_circle,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _stopListening();

                                  setState(() {
                                    recordState = 2;
                                  });
                                }),
                            2 => IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    recordState = 0;
                                  });
                                },
                              ),
                            // TODO: Handle this case.
                            int() => const Text("x"),
                          },
                          Visibility(
                              visible: recordState == 2,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.send, color: Colors.white),
                                onPressed: () {
                                  print(
                                      "$currentIndex --${tmpmsg.length}--->${tmpmsg[currentIndex + 1]["text"]}");
                                  if (_lastWords.toLowerCase() ==
                                      ( tmpmsg[currentIndex + 1]["text"]
                                              as String) 
                                          .toLowerCase().replaceAll(RegExp(r'[^a-z ]'), '')) {
                                   

                                    if (currentIndex + 2 < tmpmsg.length - 1) {
                                      setState(() {
                                        messages.add(tmpmsg[currentIndex + 1]);

                                        messages.add(tmpmsg[currentIndex + 2]);

                                        currentIndex += 2;

                                        // _lastWords =
                                        //     tmpmsg[currentIndex + 1]["text"];
                                      });
                                    } else if (currentIndex <
                                        tmpmsg.length - 1) {
                                      setState(() {
                                        messages.add(tmpmsg[currentIndex + 1]);

                                        _lastWords = "";
                                      });
                                      finshDilog();
                                    }

                                    // }
                                  } else {
                                    // print(tmpmsg[currentIndex + 1]["text"]);

                                    if (_lastWords == "") {
                                      //TODO: have end  dolog
                                    } else {
                                      checktext();
                                    }
                                  }

                                  // _sendMessage();

                                  // setState(() {
                                  //   recordState = 0;
                                  // });
                                },
                              ))

                          // _speechToText.isNotListening
                          //     ? _startListening
                          //     : _stopListening,

                          ,
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
