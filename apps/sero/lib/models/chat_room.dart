import "package:hive_flutter/adapters.dart";
import "package:sero/models/user.dart";

part "chat_room.g.dart";

@HiveType(typeId: 2)
class ChatRoom {
  @HiveField(0)
  final String chatId;
  @HiveField(1)
  final String createdAt;
  @HiveField(2)
  final User senderId;
  @HiveField(3)
  final User receiverId;

  const ChatRoom({
    required this.chatId,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatId: json["chatId"] as String,
      createdAt: json["createdAt"] as String,
      senderId: User.fromJson(json["sender"]),
      receiverId: User.fromJson(json["receiver"]),
    );
  }
}
