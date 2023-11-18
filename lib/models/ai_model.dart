import 'dart:typed_data';

class AiModel {
  final String category;
  String firstFavoriteLength;
  final String firstMessage;
  final String voiceId;
  final String id;
  final String name;
  final String prompt;
  Uint8List? image;
  AiModel({
    this.image,
    required this.category,
    required this.firstFavoriteLength,
    required this.firstMessage,
    required this.voiceId,
    required this.id,
    required this.name,
    required this.prompt,
  });
  AiModel.fromJson(json)
      : category = json["category"],
        firstFavoriteLength = json["firstFavoriteLength"],
        firstMessage = json["firstMessage"],
        voiceId = json["voiceId"],
        id = json["id"],
        name = json["name"],
        prompt = json["prompt"],
        image = null;
}

Map<String, String> categories = {
  "ruya_yorumlari": "Rüya Yorumları",
  "tarot_fali": "Tarot Falı",
  "astroloji": "Astroloji",
  "kahve_fali": "Kahve Falı",
  "iskambil_fali": "İskambil Falı",
  "numeroloji": "Numeroloji",
  "burçlar": "Burçlar",
  "melek_fali": "Melek Falı",
  "katina_fali": "Katina Falı",
  "su_fali": "Su Falı",
  "yildizname": "Yıldızname",
  "bakla_fali": "Bakla Falı",
};
