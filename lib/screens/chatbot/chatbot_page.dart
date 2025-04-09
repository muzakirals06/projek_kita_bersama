import 'package:flutter/material.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/screens/survey/survey.dart';
import 'package:sidasi/services/chatbot_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SurveyPage()),
      );
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka URL: $url';
    }
  }

  void sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text.trim();

    setState(() {
      messages.insert(0, {"text": userMessage, "type": "sent"});
    });

    String botResponse = await ChatbotService.searchFibernode(userMessage);

    setState(() {
      messages.insert(0, {"text": botResponse, "type": "received"});
    });

    _controller.clear();
  }

  Widget _buildMessageContent(Map<String, String> message) {
    String text = message["text"] ?? "";
    bool isLink = text.contains("https://www.google.com/maps");

    if (isLink && message["type"] == "received") {
      final RegExp urlPattern =
          RegExp(r'https:\/\/www\.google\.com\/maps\/place\/[^\s]+');
      final match = urlPattern.firstMatch(text);
      final url = match?.group(0) ?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.replaceAll(url, '').trim(),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchUrl(url),
            child: Text(
              '🔗 Buka Lokasi',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              ),
              child: Text(
                'SIDASI',
                style: TextStyle(
                  fontFamily: 'Nico Moji',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSent = messages[index]["type"] == "sent";
                return Align(
                  alignment:
                      isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSent ? Colors.red : Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildMessageContent(messages[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik Fibernode...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Drawing Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: 'Survey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'I-Smart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
