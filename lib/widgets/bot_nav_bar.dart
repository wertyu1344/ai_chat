import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';
import '../views/home_page.dart';

class MyBotNavBar extends StatefulWidget {
  const MyBotNavBar({Key? key}) : super(key: key);

  @override
  State<MyBotNavBar> createState() => _MyBotNavBarState();
}

class _MyBotNavBarState extends State<MyBotNavBar> {
  @override
  Widget build(BuildContext context) {
    final Controller controller = Get.find<Controller>();

    return SizedBox(
      height: 100,
      child: BottomNavigationBar(
        currentIndex: controller.botNavBarIndex.value,
        onTap: (int index) {
          controller.botNavBarIndex.value = index;
          switch (index) {
            case 0:
              Get.offAll(() => const HomePage(), duration: Duration.zero);
            case 1:
              Get.offAll(() => const HomePage(), duration: Duration.zero);
            case 2:
              Get.offAll(() => const HomePage(), duration: Duration.zero);

              break;
            default:
          }
          //  Navigator.of(context).popUntil((route) => route.isFirst);

          setState(() {});
        },
        iconSize: 32,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                "asset/images/home${controller.botNavBarIndex.value == 0 ? "" : "_deactive"}.png",
                height: 30,
                width: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Image.asset(
                "asset/images/past${controller.botNavBarIndex.value == 1 ? "" : "_deactive"}.png",
                height: 30,
                width: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Image.asset(
                "asset/images/settings${controller.botNavBarIndex.value == 2 ? "" : "_deactive"}.png",
                height: 30,
                width: 30,
              ),
              label: ""),
        ],
        backgroundColor: Colors.black,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        selectedItemColor: const Color.fromRGBO(230, 175, 47, 1),
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
