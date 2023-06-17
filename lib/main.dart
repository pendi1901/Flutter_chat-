import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
void main() {
  runApp(GroupChatApp());
}
class GroupChatApp extends StatefulWidget {
  @override
  _GroupChatAppState createState() => _GroupChatAppState();
}
class _GroupChatAppState extends State<GroupChatApp> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  late IO.Socket socket;
  @override
  void initState() {
    super.initState();
    socket = IO.io('https://21df-49-37-222-123.ngrok-free.app/', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.onConnect((_) {
      print('Connected to server');
    });
    socket.on('message', (data) {
      print(data);
      setState(() {
        _messages.add("${data['username']}: ${data['message']}");
      });
      print(_messages);
    });
  }
  void _sendMessage() {
    final message = _messageController.text;
    final username = "ritvik"; // Set the desired username here
    if (message.isNotEmpty) {
      socket.emit('message', {'username': username, 'message': message});
      _messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Chat',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Group Chat'),
        ),
        body: Column(
          children: [
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _messages.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(_messages[index]),
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  String username="";
                  String messageText="";

                  if(_messages[index].isEmpty)
                    return Container(  );
                  else if(_messages.length >=1){
                    final message = _messages[index].split(':');
                    username = message[0].trim();
                    messageText = message[1].trim();
                  }

                  return Card(
                    child: ListTile(
                      title: Text(username),
                      subtitle: Text(messageText),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
