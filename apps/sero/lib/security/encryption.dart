import "dart:convert";

import "package:cryptography/cryptography.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

/// [Keys] stores the generated public and private keys by [Encrypter].
///
/// Both [publicKey] and [privateKey] are serialized as base64.
final class Keys {
  final String algorithm;
  final String publicKey;
  final String privateKey;

  Keys({
    required this.algorithm,
    required this.publicKey,
    required this.privateKey,
  });
}

/// [Encrypter] handles generating keys for end-to-end encryption of messages.
class Encrypter {
  static final _storage = const FlutterSecureStorage();
  static final _algorithm = Ed25519();

  /// The algorithm used by [Encrypter] to generate keys, as a string.
  static final _algorithmName = "ed25519";

  static const _storePublicKeyName = "identity_public_key";
  static const _storePrivateKeyName = "identity_private_key";

  /// Returns a [Keys] object that contains base64 encoded private/public keys.
  static Future<Keys> generateKeys() async {
    final keyPair = await _algorithm.newKeyPair();

    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    final privateKeyBase64 = base64Encode(privateKey);
    final publicKeyBase64 = base64Encode(publicKey.bytes);

    return Keys(
      algorithm: _algorithmName,
      publicKey: publicKeyBase64,
      privateKey: privateKeyBase64,
    );
  }

  /// Stores the [Keys] in secure storage.
  static Future<void> storeKeys(Keys keys) async {
    await _storage.write(key: _storePublicKeyName, value: keys.publicKey);
    await _storage.write(key: _storePrivateKeyName, value: keys.privateKey);
  }
}
