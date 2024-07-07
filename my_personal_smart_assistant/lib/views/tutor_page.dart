// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, prefer_const_declarations, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatefulWidget {
  final User? user;
  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  DatabaseReference? _chatRef;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
    _speech = stt.SpeechToText();
  }

  Future<void> _initializeChatSession() async {
    final DatabaseReference userChatsRef = FirebaseDatabase.instance
        .ref()
        .child('Users/${widget.user?.uid}/Chats');

    final DataSnapshot snapshot = await userChatsRef.get();

    if (!snapshot.exists) {
      final newChatRef = userChatsRef.push();
      await newChatRef.set({
        'createdAt': DateTime.now().toIso8601String(),
      });
      _chatRef = newChatRef.child('messages');
    } else {
      final chatId = snapshot.children.first.key;
      _chatRef = userChatsRef.child('$chatId/messages');
    }
  }

  void _sendMessage(String text) async {
    final message = {
      'sender': 'user',
      'text': text,
      'timestamp': DateTime.now().toIso8601String()
    };
    print('Sending message to AI: $message');
    setState(() {
      _messages.add(message);
    });
    _controller.clear();
    _saveMessageToDatabase(message);
    _scrollToBottom();

    final response = await _fetchAIResponse(text);
    final aiMessage = {
      'sender': 'ai',
      'text': response,
      'timestamp': DateTime.now().toIso8601String()
    };
    setState(() {
      _messages.add(aiMessage);
    });
    _saveMessageToDatabase(aiMessage);
    _scrollToBottom();
  }

  Future<String> _fetchAIResponse(String query) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyAgI-ndEh8HwLu712uruo-qb8P86tOctYY';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text': query,
                }
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Response from AI: $jsonResponse');
        if (jsonResponse != null && jsonResponse.containsKey('candidates')) {
          final candidates = jsonResponse['candidates'];
          if (candidates.isNotEmpty &&
              candidates[0].containsKey('content') &&
              candidates[0]['content'].containsKey('parts') &&
              candidates[0]['content']['parts'].isNotEmpty) {
            return candidates[0]['content']['parts'][0]['text'];
          } else {
            return 'Error: AI response is empty or malformed.';
          }
        } else {
          return 'Error: AI response is empty or malformed.';
        }
      } else {
        print('Error response: ${response.body}');
        return 'Error: Unable to fetch response from AI. Status Code: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception occurred: $e');
      return 'Error: Exception occurred while fetching response from AI.';
    }
  }

  void _saveMessageToDatabase(Map<String, String> message) async {
    if (_chatRef != null) {
      await _chatRef!.push().set(message);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _listen() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      print('Microphone permission not granted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission not granted')),
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Tutor 🧑‍🎓',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1,
            color: Colors.white,
            fontFamily: 'RobotoMono', // Custom font
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 20, 20, 20),
                  const Color.fromARGB(255, 20, 20, 20)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Color.fromARGB(255, 43, 40, 40)
                                  : Color.fromARGB(255, 43, 40, 40),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: isUser
                                    ? Radius.circular(15)
                                    : Radius.circular(0),
                                bottomRight: isUser
                                    ? Radius.circular(0)
                                    : Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isUser ? 'You 🖊️' : 'Tutor 📔',
                                      style: TextStyle(
                                        color: isUser
                                            ? const Color.fromARGB(
                                                255, 255, 255, 255)
                                            : const Color.fromARGB(
                                                255, 255, 255, 255),
                                        fontSize: 12,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'RobotoMono',
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (!isUser) SizedBox(width: 4),
                                    IconButton(
                                      alignment: Alignment.topRight,
                                      icon: Icon(Icons.copy,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          size: 16),
                                      onPressed: () =>
                                          _copyToClipboard(message['text']!),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  message['text']!,
                                  style: TextStyle(
                                    color: isUser
                                        ? const Color.fromARGB(
                                            255, 255, 255, 255)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255),
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                    wordSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "What you want to learn 🧐",
                            hintStyle: TextStyle(
                              fontFamily: 'RobotoMono',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepPurple,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_isListening)
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple,
                          child: IconButton(
                            icon: Icon(Icons.stop, color: Colors.white),
                            onPressed: _stopListening,
                          ),
                        ),
                      if (!_isListening)
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple,
                          child: IconButton(
                            icon: Icon(Icons.mic_none, color: Colors.white),
                            onPressed: _listen,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isListening)
            Center(
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 50.0,
              ),
            ),
        ],
      ),
    );
  }
}
