import 'package:encrypt/encrypt.dart';

class Message {
  Message(String message) {
    _message = message;
  }
  encryptAndSendMessage() {
    final encrypter = Encrypter(Salsa20(key));
    final encrypted = encrypter.encrypt(_message, iv: iv);
    print(encrypted.base64);
    //TODO: write message to cloud firestore
  }

  decryptRecivedMessage() {
    final encrypter = Encrypter(Salsa20(key));
    final encryptedBase64 = encrypter
        .encrypt(_message, iv: iv)
        .base64; //TODO: read message from cloud firestore
    final decrypted =
        encrypter.decrypt(Encrypted.fromBase64(encryptedBase64), iv: iv);
    print(decrypted);
  }

  String _message;
  String sender;
  String reciever;
  final key = Key.fromLength(32);
  final iv = IV.fromLength(8);
}
