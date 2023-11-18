import 'package:ai_chat/models/ai_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/controller.dart';
import '../controller/message_controller.dart';
import '../models/notif_model.dart';
import '../models/user_model.dart';

class FirebaseCloudServices {
  final _firebase = FirebaseFirestore.instance;
  Controller controller = Get.find<Controller>();

  GetStorage box = GetStorage();
  Future<AiModel?> getFortuneTellerWithId(String id) async {
    AiModel? fortuneTellerModel;
    await _firebase
        .collection("fortuneTellers")
        .where("id", isEqualTo: id)
        .get()
        .then((value) =>
            fortuneTellerModel = AiModel.fromJson(value.docs.first.data()));
    return fortuneTellerModel;
  }

  Future<UserModel?> createUser(String deviceID) async {
    MessageController messagesController = Get.find<MessageController>();

    try {
      await _firebase.collection("user").doc(deviceID).set({
        "messageCredit": messagesController.numberOfMessagePerDay,
        "lastLoginDate": Timestamp.fromDate(DateTime.now())
      });
      return UserModel(
          lastLoginDate: DateTime.now(),
          messageCredit: messagesController.numberOfMessagePerDay);
    } catch (e) {}
    return null;
  }

  Future<UserModel?> getUser(String deviceID) async {
    UserModel? user;

    await _firebase.collection("user").doc(deviceID).get().then((value) {
      if (value.data() != null) {
        user = UserModel.fromJson(value.data()!);
      }
    });
    return user;
  }

  Future<UserModel?> deleteUser(String deviceID) async {
    UserModel? user;

    await _firebase.collection("user").doc(deviceID).delete();
    return user;
  }

  Future<void> updateUserLastLoginDateAndCredit(String deviceID) async {
    MessageController messagesController = Get.find<MessageController>();

    await _firebase.collection("user").doc(deviceID).update({
      "lastLoginDate": Timestamp.fromDate(DateTime.now()),
      "messageCredit": messagesController.numberOfMessagePerDay
    });
  }

  Future<void> updateUserCredit(String deviceID, credit) async {
    await _firebase.collection("user").doc(deviceID).update({
      "messageCredit": credit,
    });
  }

  Future<List<AiModel>?> getFortuneTellers(String fortuneCategory) async {
    List<AiModel> fortuneTellers = [];
    print("forune kaetgöri $fortuneCategory");
    try {
      var docs = await _firebase
          .collection("ai_models")
          .where("category", isEqualTo: fortuneCategory)
          .get();
      for (var element in docs.docs) {
        if (element.exists) {
          fortuneTellers.add(AiModel.fromJson(element.data()));
        }
      }
      print("ailar geldi");

      print(fortuneTellers);
      return fortuneTellers;
    } catch (e) {
      print("hata $e");
    }
    return fortuneTellers;
  }

  updateUniqueMessage(id) async {
    // Firebase Firestore referansını alın
    final firestore = FirebaseFirestore.instance;

    try {
      // 'reports' koleksiyonundaki 'reports' belgesini alın
      DocumentReference reportRef =
          firestore.collection('fortuneTellers').doc(id);

      // Belgeyi alın ve mevcut 'uniqueMessage' değerini alın
      DocumentSnapshot snapshot = await reportRef.get();
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        int currentUniqueMessage = data['uniqueMessage'] ?? 0;

        // uniqueMessage değerini 1 arttırın
        int updatedUniqueMessage = currentUniqueMessage + 1;

        // Güncellenmiş değeri belgeye yazın
        await reportRef.update({'uniqueMessage': updatedUniqueMessage});
      } else {}
    } catch (e) {
      // Hata durumunda burada ele alabilirsiniz
    }
  }

  increaseFortuneLike(id) async {
    // Firebase Firestore referansını alın
    final firestore = FirebaseFirestore.instance;

    try {
      // 'reports' koleksiyonundaki 'reports' belgesini alın
      DocumentReference reportRef =
          firestore.collection('fortuneTellers').doc(id);

      // Belgeyi alın ve mevcut 'uniqueMessage' değerini alın
      DocumentSnapshot snapshot = await reportRef.get();
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        int currentUniqueMessage = int.parse(data['firstFavoriteLength']);

        // uniqueMessage değerini 1 arttırın
        int updatedUniqueMessage = currentUniqueMessage + 1;

        // Güncellenmiş değeri belgeye yazın
        await reportRef
            .update({'firstFavoriteLength': updatedUniqueMessage.toString()});
      } else {}
    } catch (e) {
      // Hata durumunda burada ele alabilirsiniz
    }
  }

  deleteFortuneLike(id) async {
    // Firebase Firestore referansını alın
    final firestore = FirebaseFirestore.instance;

    try {
      // 'reports' koleksiyonundaki 'reports' belgesini alın
      DocumentReference reportRef =
          firestore.collection('fortuneTellers').doc(id);

      // Belgeyi alın ve mevcut 'uniqueMessage' değerini alın
      DocumentSnapshot snapshot = await reportRef.get();
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        int currentUniqueMessage = int.parse(data['firstFavoriteLength']);

        // uniqueMessage değerini 1 arttırın
        int updatedUniqueMessage = currentUniqueMessage - 1;

        // Güncellenmiş değeri belgeye yazın
        await reportRef
            .update({'firstFavoriteLength': updatedUniqueMessage.toString()});
      } else {}
    } catch (e) {
      // Hata durumunda burada ele alabilirsiniz
    }
  }

  updateTotalDownload() async {
    // Firebase Firestore referansını alın
    bool isFirstLogin = box.read("isFirstLogin") == true ? false : true;
    final firestore = FirebaseFirestore.instance;
    if (isFirstLogin) {
      try {
        // 'reports' koleksiyonundaki 'reports' belgesini alın
        DocumentReference reportRef =
            firestore.collection('reports').doc("reports");

        // Belgeyi alın ve mevcut 'uniqueMessage' değerini alın
        DocumentSnapshot snapshot = await reportRef.get();
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          int currentUniqueMessage = data['totalDownload'] ?? 0;

          // uniqueMessage değerini 1 arttırın
          int updatedUniqueMessage = currentUniqueMessage + 1;

          // Güncellenmiş değeri belgeye yazın
          await reportRef.update({'totalDownload': updatedUniqueMessage});
          await box.write("isFirstLogin", true);
        } else {}
      } catch (e) {
        // Hata durumunda burada ele alabilirsiniz
      }
    }
  }

  Future<Map<String, dynamic>?> getMessageController() async {
    try {
      Map<String, dynamic>? a;

      await _firebase
          .collection("controller")
          .doc("controller")
          .get()
          .then((value) => a = value.data());

      return a;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<List<NotifModel>?> getNotifications() async {
    List<NotifModel> notifs = [];
    try {
      await _firebase.collection("notifications").get().then((value) {
        for (var element in value.docs) {
          var temp = NotifModel.fromJson(element.data());
          notifs.add(temp);
        }
      });
      return notifs;
    } catch (e) {
      return null;
    }
  }
}
