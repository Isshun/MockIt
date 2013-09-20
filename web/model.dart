import 'dart:html';
import 'dart:async';
import 'package:json_object/json_object.dart';
import 'models/user.dart';

class Model {
  WebSocket _ws;
  var _listener;
  UserModel _user;

  Model(UserModel user) {
    _user = user;
    initWebSocket('ws://127.0.0.1:8124/ws');    
  }
  
  void setOnUpdateListener(listener) {
    _listener = listener;
  }
  
  void send(String msg) {
    _ws.send(msg);
  }
  
  outputMsg(String msg) {
    print(msg);
//  var output = query('#output');
//  output.text = "${output.text}\n${msg}";
  }
  
  void initWebSocket(String url, [int retrySeconds = 2]) {
    var encounteredError = false;
    
    outputMsg("Connecting to Web socket");
    _ws = new WebSocket(url);
    
    _ws.onOpen.listen((e) {
      outputMsg('Connected');
      DateTime now = new DateTime.now();
      _ws.send('alex'+' '+now.toString());
    });
    
    _ws.onClose.listen((e) {
      outputMsg('web socket closed, retrying in $retrySeconds seconds');
      if (!encounteredError) {
        new Timer(new Duration(seconds:retrySeconds),
            () => initWebSocket(url, retrySeconds*2));
      }
      encounteredError = true;
    });
    
    _ws.onError.listen((e) {
      outputMsg("Error connecting to ws");
      if (!encounteredError) {
        new Timer(new Duration(seconds:retrySeconds),
            () => initWebSocket(url, retrySeconds*2));
      }
      encounteredError = true;
    });
    
    _ws.onMessage.listen((MessageEvent e) {
//    var data = parse(e.data);
      var msg = new JsonObject.fromJsonString(e.data);

//    String type = data["type"].toString();
      switch (msg.type) {
        case 'hello':
          _ws.send('{"cmd": "getWorkspace"}');
          _user.color = msg.data.color;
          _user.name = msg.data.user;
          
          UListElement ul = query("#user");
          LIElement li = new LIElement();
          li.style.color = _user.color;
          li.text = _user.name;
          ul.append(li);
          
          print("hello " + _user.name);
          break;
        case 'model':
          outputMsg('received model');
          _listener(msg.objects);
          break;
      }
    });
  }
}
