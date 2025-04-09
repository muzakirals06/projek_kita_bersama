import 'package:flutter/material.dart';
import 'package:sidasi/screens/home_page.dart';
import '../services/file_service.dart';
import 'profile_page.dart';
import 'survey/survey.dart';
import 'package:sidasi/screens/chatbot/chatbot_page.dart';
import 'package:sidasi/services/dialog_service.dart';

class PdfListPage extends StatefulWidget {
  final String searchQuery;
  PdfListPage({required this.searchQuery});

  @override
  _PdfListPageState createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  List<Map<String, dynamic>> _fileList = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      List<Map<String, dynamic>> files =
          await FileService.fetchFiles(widget.searchQuery);

      List<Map<String, dynamic>> filteredFiles = files.where((file) {
        String fileName = file['file_name']?.toLowerCase() ?? '';
        return fileName.endsWith('.pdf') || fileName.endsWith('.kmz');
      }).toList();

      setState(() {
        _fileList = files;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching files: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAndOpenFile(String fileId, String fileName) async {
    await FileService.downloadAndOpenFile(context, fileId, fileName);
  }

  void _searchFile() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PdfListPage(searchQuery: query),
        ),
      );
    }
  }

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatbotPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hilangkan tombol panah back
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Masukkan Nama File",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _searchFile,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) => _searchFile(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _fileList.isEmpty
                    ? Center(child: Text("Tidak ada file ditemukan."))
                    : ListView.builder(
                        itemCount: _fileList.length,
                        itemBuilder: (context, index) {
                          final file = _fileList[index];
                          String fileName = file['file_name'];
                          String? iconPath;

                          if (fileName.endsWith('.pdf')) {
                            iconPath = 'assets/img/pdficon.png';
                          } else if (fileName.endsWith('.kmz')) {
                            iconPath = 'assets/img/kmzicon.png';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: iconPath != null
                                    ? Image.asset(iconPath,
                                        width: 40, height: 40)
                                    : null,
                                title: Text(
                                  fileName,
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: TextButton(
                                  onPressed: () => _downloadAndOpenFile(
                                      file['id'], file['file_name']),
                                  //jika websocket telah siap ganti dengan PermissionDialog.showRequestPermissionDialog(context, file['id'], file['file_name']),
                                  child: Text(
                                    "View",
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Drawing Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: "Survey",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "I-Smart",
          ),
        ],
      ),
    );
  }
}
