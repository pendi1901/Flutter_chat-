import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      print('Connected to the server');
      // socket.emit('joinGroup', _selectedGroup); // Join the default group
    });
    socket.on('messages', (data) {
      print(data);
      List<dynamic> messages = data['messages'];
      setState(() {
        _messages.clear();
        messages.forEach((message) {
          _messages.add(
              "${message['username']}: ${message['message']}, ${message['created']}");
        });
      });
    });
    socket.on('message', (data) {
      print(data);
      setState(() {
        _messages
            .add("${data['username']}: ${data['message']}, ${data['created']}");
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
        backgroundColor: Color(0xff00002D),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            children: [
              Icon(Icons.monitor_heart),
              SizedBox(width: 8),
              Text('Global Chat: $_selectedGroup'),
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
                title: Text('Global Chat'),
                subtitle:Column (
                  mainAxisAlignment: MainAxisAlignment.start,
                    children:[Text('Welcome to the Global Chat'),Text('This is where Kalakumbh comes to talk!'),]),
                onTap: () => _changeGroup('group1'),
              ),
              ListTile(
                title: Text('Singers'),
                onTap: () => _changeGroup('group2'),
              ),
              ListTile(
                title: Text('Instrumentalists'),
                onTap: () => _changeGroup('group3'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: 10000,
              height: 50,
              color: Colors.black,
              child: Center(
                  child: Text(
                "Welcome to the Global Chat",
                style: TextStyle(color: Colors.white, fontSize: 25),
              )),
            ), // Group Chat
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  String username = "";
                  String messageText = "";

                  // final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                  if (_messages[index].isEmpty) return Container();
                  final message = _messages[index].split(':');
                  username = message[0].trim();
                  messageText = message[1].split(',')[0].trim();
                  final timestamp = message[1].split(',')[1].trim();
                  print(timestamp.runtimeType);
                  // convert timestamp to an int
                  final int timestamp1 =
                      int.parse(message[1].split(',')[1].trim());
                  print(timestamp1.runtimeType);
                  print(timestamp1);
                  // convert timestamp to a DateTime object
                  final DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestamp1);
                  print(dateTime);
                  String formattedDateTime =
                      DateFormat('HH:mm').format(dateTime);
                  print(formattedDateTime);
                  // final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

                  return Card(
                    color: Color(0xff00002D),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            username,
                            style:
                                TextStyle(color: Colors.yellow, fontSize: 22),
                          ),
                          Text(
                            formattedDateTime,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                      subtitle: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            messageText,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
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
