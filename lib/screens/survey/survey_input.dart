import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidasi/services/survey_service.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/smart/chatbot.dart';

class SurveyInputPage extends StatefulWidget {
  final Map<String, dynamic> survey;

  SurveyInputPage({required this.survey});

  @override
  _SurveyInputPageState createState() => _SurveyInputPageState();
}

class _SurveyInputPageState extends State<SurveyInputPage> {
  String? selectedResult;
  final TextEditingController _remarkController = TextEditingController();
  bool _isLoading = false;
  int _selectedIndex = 1; // Index menu survey
  File? selectedImage;

  // Pilihan hasil survey
  final List<String> resultOptions = ["STANDART", "REJECT", "INCOMPLETE"];

  // Fungsi memilih sumber gambar (Kamera atau Galeri)
  Future<void> selectImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.orange),
              title: Text("Ambil dari Kamera"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.orange),
              title: Text("Pilih dari Galeri"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi mengambil gambar dari kamera atau galeri
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi menyimpan hasil survey
  Future<void> _submitSurvey() async {
    if (selectedResult == null ||
        _remarkController.text.isEmpty ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mohon lengkapi semua data sebelum menyimpan!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SurveyService.updateSurvey(widget.survey['id'], {
        "result": selectedResult,
        "remark": _remarkController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Survey berhasil diperbarui")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memperbarui survey")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Navigasi bottom bar
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ChatbotPage()));
    }
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
                  (route) => false),
              child: Text('SIDASI',
                  style: TextStyle(
                      fontFamily: 'Nico Moji',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul survey
              Text(widget.survey['title'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              // Dropdown Result
              Text("Hasil Survey"),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ExpansionTile(
                  title: Text(selectedResult ?? "Pilih hasil survey"),
                  children: resultOptions.map((result) {
                    return ListTile(
                      title: Text(result),
                      onTap: () {
                        setState(() {
                          selectedResult = result;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),

              // Remark
              Text("Catatan Tambahan"),
              SizedBox(height: 8),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan catatan...",
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Input Gambar
              Text("Upload Gambar"),
              SizedBox(height: 8),
              GestureDetector(
                onTap: selectImageSource,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey),
                            Text("Tambah Gambar",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : Image.file(selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),

              // Tombol Simpan
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitSurvey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text("Simpan",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Drawing Map"),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: "Survey"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "I-Smart"),
        ],
      ),
    );
  }
}
