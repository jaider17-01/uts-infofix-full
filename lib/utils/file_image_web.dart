import 'package:flutter/material.dart';

Widget buildFileImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  return Container(
    width: width, height: height,
    color: const Color(0xFFEEEEEE),
    child: const Center(child: Icon(Icons.image_rounded, color: Colors.grey, size: 32)),
  );
}

