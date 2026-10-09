import 'dart:io';
import 'package:flutter/material.dart';

Widget buildFileImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(path),
    width: width, height: height, fit: fit,
    errorBuilder: (_, __, ___) => Container(
      width: width, height: height,
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.broken_image_rounded, color: Colors.grey)),
  );
}

