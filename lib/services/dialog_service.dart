import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../screens/permission_dialog.dart';
import 'file_service.dart';

class DialogService {
  static IOWebSocketChannel? _channel;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> showPermissionDialog(
      BuildContext context, String fileId, String fileName) async {
    print("✔️ Menampilkan dialog diijinkan");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final sessionToken = prefs.getString('session_token') ?? '';

    if (userId.isEmpty || sessionToken.isEmpty) {
      print("User ID atau token tidak ditemukan");
      return;
    }

    // 1. Buka koneksi WebSocket
    _channel = IOWebSocketChannel.connect(
      Uri.parse('ws://192.168.1.4:3000/api/v1/ws/notif'),
      headers: {
        'Authorization': 'Bearer $sessionToken',
      },
    );

    // 2. Dengarkan notifikasi balasan dari admin
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      print("Received from websocket: $message");

      final status = data['notify_status'];
      final receivedFileId = data['file_id'];

      if (receivedFileId == fileId) {
        final context = navigatorKey.currentContext;
        print("Status dari server: $status");
        if (context != null) {
          if (status == "approve") {
            print("✔️ Memunculkan dialog diijinkan");
            PermissionDialog.showPermissionResponseDialog(
              context,
              true,
              () {
                FileService.downloadAndOpenFile(context, fileId, fileName);
                _channel?.sink.close();
              },
            );
          } else if (status == "reject") {
            print("❌ Memunculkan dialog ditolak");
            PermissionDialog.showPermissionResponseDialog(
              context,
              false,
              () {
                Navigator.pop(context); // tutup dialog
                _channel?.sink.close();
              },
            );
          }
        } else {
          print("⚠️ Context is null, tidak bisa menampilkan dialog");
        }
      }
    });

    // 3. Tampilkan dialog "Minta Izin"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("Minta Izin"),
          content: Text("Minta izin untuk membuka file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _channel?.sink.close();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _sendPermissionRequest(userId, fileId, sessionToken);
              },
              child: Text("Minta"),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _sendPermissionRequest(
      String userId, String fileId, String token) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://192.168.1.4:3000/api/v1/files/request',
        data: {
          "user_id": userId,
          "file_id": fileId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Request berhasil dikirim ke admin.");
      } else {
        print("Gagal mengirim request: ${response.statusCode}");
      }
    } catch (e) {
      print("Error kirim request: $e");
    }
  }

  static void disposeWebSocket() {
    _channel?.sink.close(status.normalClosure);
    _channel = null;
  }
}
