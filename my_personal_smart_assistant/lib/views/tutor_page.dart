// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final User? user;
  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  DatabaseReference? _chatRef;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
  }

  Future<void> _initializeChatSession() async {
    final DatabaseReference userChatsRef = FirebaseDatabase.instance
        .ref()
        .child('Users/${widget.user?.uid}/Chats');

    final DataSnapshot snapshot = await userChatsRef.get();

    if (!snapshot.exists) {
      // Create a new chat session if it doesn't exist
      final newChatRef = userChatsRef.push();
      await newChatRef.set({
        'createdAt': DateTime.now().toIso8601String(),
      });
      _chatRef = newChatRef.child('messages');
    } else {
      // Use the existing chat session
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
        print('Response from AI: $jsonResponse'); // Print the entire response
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Tutor')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    message['text']!,
                    style: TextStyle(
                      color: message['sender'] == 'user'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  subtitle: Text(message['sender']!),
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
                    decoration: InputDecoration(hintText: 'Type your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
