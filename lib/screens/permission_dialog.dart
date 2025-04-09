import 'package:flutter/material.dart';

class PermissionDialog {
  static void showPermissionResponseDialog(
    BuildContext context,
    bool isApproved,
    VoidCallback onAction,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.orange[100], // warna latar oranye muda
          title: Text(
            "Izin Akses",
            style: TextStyle(color: Colors.deepOrange),
          ),
          content: Text(
            isApproved ? "Anda telah diizinkan" : "Anda tidak diizinkan",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tutup",
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
            if (isApproved)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAction(); // buka file
                },
                child: Text(
                  "Buka",
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
