import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width / 4)),
            child: Image.asset(
              "asset/images/empty_page_past_fortunes.png",
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Henüz Bildirimin Yok",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
