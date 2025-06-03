import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebSocketPage(),
    );
  }
}

class WebSocketPage extends StatefulWidget {
  const WebSocketPage({super.key});

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  late WebSocketChannel channel;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://192.168.137.1:5000/'));
      isConnected = true;

      // Listen for messages from the server
      channel.stream.listen(
        (message) {
          if (message == "Done") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gửi thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (message == "Error") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gửi thất bại!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi kết nối: $error'),
              backgroundColor: Colors.red,
            ),
          );
          isConnected = false;
        },
        onDone: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mất kết nối với server'),
              backgroundColor: Colors.red,
            ),
          );
          isConnected = false;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối: $e'),
          backgroundColor: Colors.red,
        ),
      );
      isConnected = false;
    }
  }

  void _sendMessage(String message) {
    if (isConnected) {
      channel.sink.add(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có kết nối với server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton('A1'),
                const SizedBox(width: 20),
                _buildButton('A2'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton('B1'),
                const SizedBox(width: 20),
                _buildButton('B2'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () => _sendMessage(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }
}
