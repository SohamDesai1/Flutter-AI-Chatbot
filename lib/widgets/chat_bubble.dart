import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sizer/sizer.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String isUser;
  final String? image;

  const ChatBubble(
      {super.key, required this.message, required this.isUser, this.image});

  @override
  Widget build(BuildContext context) {
    if (image != null && isUser == "user") {
      return Container(
        margin: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: isUser == "user" ? 12.w : 1.h,
            right: isUser == "user" ? 1.h : 12.w),
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: isUser == "user" ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser == "user" ? 16.0 : 0.0),
            topRight: Radius.circular(isUser == "user" ? 0.0 : 16.0),
            bottomRight: const Radius.circular(16.0),
            bottomLeft: const Radius.circular(16.0),
          ),
        ),
        child: Row(
          children: [
            Image.file(File(image!)),
            SizedBox(
              width: 3.w,
            ),
            MarkdownBody(data: message)
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: isUser == "user" ? 12.w : 1.h,
            right: isUser == "user" ? 1.h : 12.w),
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: isUser == "user" ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser == "user" ? 16.0 : 0.0),
            topRight: Radius.circular(isUser == "user" ? 0.0 : 16.0),
            bottomRight: const Radius.circular(16.0),
            bottomLeft: const Radius.circular(16.0),
          ),
        ),
        child: MarkdownBody(
          data: message,
        ),
      );
    }
  }
}
