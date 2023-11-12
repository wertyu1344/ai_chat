class MessageModel {
  final String text;
  final bool isMe;
  bool isPrompt;

  MessageModel(
      {required this.text, required this.isMe, required this.isPrompt});
}
