import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/survey/survey.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  int _selectedIndex = 2;

  // Fungsi untuk menangani navigasi pada bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      
    });

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

  // Fungsi untuk membaca file Excel dari assets
  Future<List<List<String>>> readExcel() async {
    ByteData data = await rootBundle.load("assets/ismart/i-smart.xlsx");
    Uint8List bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    List<List<String>> excelData = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        excelData.add(row.map((cell) => cell?.value.toString() ?? "").toList());
      }
    }

    return excelData;
  }

  // Fungsi untuk mencari Fibernode di file Excel
  Future<String> searchFibernode(String fibernode) async {
    List<List<String>> data = await readExcel();

    for (var row in data) {
      if (row.length > 3 && row[1].toLowerCase() == fibernode.toLowerCase()) {
        String alamat = row[2]; // Kolom C
        String koordinat = row[3]; // Kolom D
        String locationUrl = "https://www.google.com/maps/place/$koordinat";

        return "Data Fibernode ditemukan:\n"
            "Fibernode: $fibernode\n"
            "Alamat: $alamat\n"
            "Koordinat: $koordinat\n"
            "Location: $locationUrl";
      }
    }

    return "First Squad BU4 - Strong Together";
  }

  // Fungsi untuk menangani pengiriman pesan
  void sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text.trim();

    setState(() {
      messages.insert(0, {"text": userMessage, "type": "sent"});
    });

    String botResponse = await searchFibernode(userMessage);

    setState(() {
      messages.insert(0, {"text": botResponse, "type": "received"});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text(
            'SIDASI',
            style: TextStyle(
              fontFamily: 'Nico Moji',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFEAF27),
            ),
          ),
        ),
        centerTitle: true,
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
                    child: Text(
                      messages[index]["text"]!,
                      style: TextStyle(color: Colors.white),
                    ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
