import 'package:ai_chat/views/ai_categories.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';
import '../models/ai_model.dart';
import '../widgets/app_bar_notif_button.dart';
import '../widgets/main_app_bar.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  Controller controller = Get.put(Controller());
  @override
  void initState() {
    //initPlatformState();
    super.initState();
  }

  /*Future<void> initPlatformState() async {
    appData.appUserID = await Purchases.appUserID;
    controller.userId.value = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      appData.appUserID = await Purchases.appUserID;
      controller.userId.value = await Purchases.appUserID;

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
      appData.entitlementIsActive = entitlement?.isActive ?? false;
      controller.isPremiumActive.value = entitlement?.isActive ?? false;

      setState(() {});
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          /*   MainAppBar(
            title: "Yapay Zeka ile Falına Bak",
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Image.asset(
                    "asset/images/diamond.png",
                    width: 50,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.myMessageCredit.value.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
            action: AppBarNotifButton(),
          ),*/
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              /* gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 8, crossAxisCount: 2, mainAxisSpacing: 8),*/
              itemCount: 12,
              itemBuilder: (context, index) {
                return AiCategories(
                  fortuneKey: categories.keys.toList()[index],
                  imagePath: "asset/images/fortune_images/${index + 1}.png",
                  index: index,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
