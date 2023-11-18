import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  const NotificationWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromRGBO(230, 175, 47, 1),
            )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color.fromRGBO(230, 175, 47, 1), width: 2)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "asset/icon.png",
                  width: 60,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                  ),
                  Text(
                    content,
                  ),
                  Text(
                    date,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
