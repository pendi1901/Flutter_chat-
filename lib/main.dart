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
  String _selectedGroup = 'group1'; // Default selected group

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://localhost:3000/', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joinGroup', _selectedGroup); // Join the default group
    });
    socket.on('messages', (data) {
      print(data);
      List<dynamic> messages = data['messages'];
      setState(() {
        _messages.clear();
        messages.forEach((message) {
          _messages.add("${message['username']}: ${message['message']}");
        });
      });
    });
    socket.on('message', (data) {
      print(data);
      setState(() {
        _messages.add("${data['username']}: ${data['message']}");
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    final username = "ritvik"; // Set the desired username here
    if (message.isNotEmpty) {
      socket.emit('message', {
        'username': username,
        'message': message,
        'groupId': _selectedGroup,
      });
      _messageController.clear();
    }
  }

  void _changeGroup(String groupId) {
    setState(() {
      _selectedGroup = groupId;
      _messages.clear();
    });
    socket.emit('joinGroup', groupId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Chat',
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.group),
              SizedBox(width: 8),
              Text('Group: $_selectedGroup'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Groups',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Group 1'),
                onTap: () => _changeGroup('group1'),
              ),
              ListTile(
                title: Text('Group 2'),
                onTap: () => _changeGroup('group2'),
              ),
              ListTile(
                title: Text('Group 3'),
                onTap: () => _changeGroup('group3'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  String username = "";
                  String messageText = "";

                  if (_messages[index].isEmpty) return Container();
                  final message = _messages[index].split(':');
                  username = message[0].trim();
                  messageText = message[1].trim();

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
