import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidasi/screens/survey/wo_detail.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/services/survey_service.dart';
import 'package:sidasi/smart/chatbot.dart';
import 'package:sidasi/screens/survey/survey_input.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<dynamic> _surveys = [];
  bool _isLoading = true;
  int _selectedIndex = 1; // Index menu survey

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

  Future<void> _fetchSurveys() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId != null) {
        List<dynamic> surveys = await SurveyService.fetchSurveys(userId);
        print("✅ Data survey berhasil diambil: $surveys");

        setState(() {
          _surveys = surveys;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error saat mengambil survey: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SurveyPage()));
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
      body: Column(
        children: [
          // 🔥 Judul "Daftar WO"
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar WO",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🔥 ListView dengan desain terbaru
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _surveys.isEmpty
                    ? Center(child: Text("Tidak ada survey tersedia"))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _surveys.length,
                        itemBuilder: (context, index) {
                          final survey = _surveys[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                // 🔥 Navigasi ke halaman detail survey (wo_detail.dart)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WoDetailPage(survey: survey),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                decoration: BoxDecoration(
                                  color:
                                      Color(0xFFF9C784), // Warna sesuai desain
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 🔹 Nama Work Order dari "title"
                                    Expanded(
                                      child: Text(
                                        survey['title'] ?? "Work Order",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                    // ✏️ Ikon Edit (hanya ikon yang bisa diklik)
                                    GestureDetector(
                                      onTap: () {
                                        // 🔥 Navigasi ke halaman edit survey (survey_input.dart)
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SurveyInputPage(
                                              survey: survey,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black87,
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
        ],
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
