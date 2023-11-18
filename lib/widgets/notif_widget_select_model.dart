import 'package:flutter/material.dart';

class NotificationWidgetSelectModel extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final bool buttonValue;
  final Function onTap;
  final int index;
  const NotificationWidgetSelectModel(
      {super.key,
      required this.title,
      required this.content,
      required this.date,
      required this.buttonValue,
      required this.onTap,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color.fromRGBO(230, 175, 47, 1), width: 2)),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color.fromRGBO(230, 175, 47, 1),
                            width: 2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "asset/icon.png",
                        width: 88,
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
                        SizedBox(
                          height: 2,
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
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: 60,
          color: Colors.black,
          height: 100,
          child: Transform.scale(
            scale: 1.3,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Checkbox(
                tristate: false,
                fillColor: const MaterialStatePropertyAll(Colors.transparent),
                overlayColor: MaterialStatePropertyAll(
                    buttonValue ? Colors.white : Colors.transparent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                value: buttonValue,
                onChanged: (value) => onTap(index),
              ),
            ),
          ),
        )
      ],
    );
  }
}
