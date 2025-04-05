import 'package:flutter/material.dart';
import 'package:sidasi/screens/survey/survey_input.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/smart/chatbot.dart';

class WoDetailPage extends StatelessWidget {
  final dynamic survey;

  WoDetailPage({required this.survey});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WoDetailPage(survey: survey)));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WO",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(survey['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),

            // Menampilkan detail survey
            Text("Form Number: ${survey['form_number']}"),
            Text("Requestor Name: ${survey['questor_name']}"),
            Text("FAT: ${survey['fat']}"),
            Text("Customer Name: ${survey['customer_name']}"),
            Text("Address: ${survey['address']}"),
            Text("Node FDT: ${survey['node_fdt']}"),
            Text("Survey Date: ${survey['survey_date']}"),

            SizedBox(height: 20),

            // Menampilkan gambar dari survey
            survey['image_id'] != null
                ? Image.network(
                    "http://192.168.1.12:3000/api/v1/files/download?id=${survey['image_id']}",
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),

            SizedBox(height: 20),

            // Tombol Isi Hasil Survey
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SurveyInputPage(survey: survey)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Isi Hasil Survey",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      // Footer Navigasi
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.black,
        currentIndex: 1,
        onTap: (index) => _onItemTapped(context, index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Drawing Map"),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: "Survey"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "I-Smart"),
        ],
      ),
    );
  }
}
