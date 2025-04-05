import 'package:flutter/material.dart';

class PermissionDialog extends StatelessWidget {
  final String fileName;
  const PermissionDialog({Key? key, required this.fileName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Izin Akses"),
      content: Text("Apakah Anda ingin meminta izin admin untuk membuka file '$fileName'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Tolak"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Izinkan"),
        ),
      ],
    );
  }
}