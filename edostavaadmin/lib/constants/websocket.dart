import 'package:web_socket_channel/io.dart';

class WebSocketHandler {
  final String serverUrl;
  late final IOWebSocketChannel _channel;

  WebSocketHandler(this.serverUrl) {
    _channel = IOWebSocketChannel.connect(serverUrl);
  }

  void sendToAllAsync(String message) {
    _channel.sink.add(message);
  }

  Stream<dynamic> get onMessage => _channel.stream;

  void dispose() {
    _channel.sink.close();
  }
}
