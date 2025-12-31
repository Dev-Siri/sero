import "package:hive_flutter/adapters.dart";
import "package:sero/models/user.dart";

class UserAdapter extends TypeAdapter<User> {
  @override
  int get typeId => 1;

  @override
  User read(BinaryReader reader) {
    return User(
      userId: reader.readString(),
      phone: reader.readString(),
      createdAt: reader.readString(),
      displayName: reader.readBool() ? reader.readString() : null,
      statusText: reader.readBool() ? reader.readString() : null,
      pictureUrl: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, User user) {
    writer.writeString(user.userId);
    writer.writeString(user.phone);
    writer.writeString(user.createdAt);
    writer.writeBool(user.displayName != null);
    if (user.displayName != null) {
      writer.writeString(user.displayName!);
    }

    writer.writeBool(user.statusText != null);
    if (user.statusText != null) {
      writer.writeString(user.statusText!);
    }

    writer.writeBool(user.pictureUrl != null);
    if (user.pictureUrl != null) {
      writer.writeString(user.pictureUrl!);
    }
  }
}
