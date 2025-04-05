import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidasi/screens/survey/survey_input.dart';
import 'package:sidasi/screens/survey/survey.dart';
import 'package:sidasi/screens/home_page.dart';
import 'package:sidasi/screens/profile_page.dart';
import 'package:sidasi/smart/chatbot.dart';
import 'package:sidasi/services/survey_service.dart';

class WoDetailPage extends StatelessWidget {
  final dynamic survey;

  WoDetailPage({required this.survey});

  void _onItemTapped(BuildContext context, int index) {
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
            SizedBox(height: 5),

            // Menampilkan detail survey
            Text(
              "Form Number: ${survey['form_number']}",
              style: TextStyle(fontSize: 16),
            ),
            Text("Requestor Name: ${survey['questor_name']}",
                style: TextStyle(fontSize: 16)),
            Text("FAT: ${survey['fat']}", style: TextStyle(fontSize: 16)),
            Text("Customer Name: ${survey['customer_name']}",
                style: TextStyle(fontSize: 16)),
            Text("Address: ${survey['address']}",
                style: TextStyle(fontSize: 16)),
            Text("Node FDT: ${survey['node_fdt']}",
                style: TextStyle(fontSize: 16)),
            Text("Survey Date: ${survey['survey_date']}",
                style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            // Menampilkan gambar dari survey dengan autentikasi
            survey['image_id'] != null
                ? FutureBuilder(
                    future: SurveyService.getSurveyImageUrl(survey['image_id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Container(
                          height: 300,
                          color: Colors.grey[300],
                          child: Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.red)),
                        );
                      } else {
                        final imageUrl = snapshot.data!['url'];
                        final headers = snapshot.data!['headers'];

                        return FutureBuilder<Response<List<int>>>(
                          future: Dio().get<List<int>>(
                            imageUrl,
                            options: Options(
                              responseType: ResponseType.bytes,
                              headers: headers,
                            ),
                          ),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 300,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else if (imageSnapshot.hasError ||
                                imageSnapshot.data == null) {
                              return Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.broken_image,
                                      size: 100, color: Colors.grey),
                                ),
                              );
                            } else {
                              return Image.memory(
                                Uint8List.fromList(imageSnapshot.data!.data!),
                                height: 300,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        );
                      }
                    },
                  )
                : Container(
                    height: 300,
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
