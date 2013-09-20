import 'dart:html';
import 'dart:collection';
import 'dart:async';
import 'dart:json';
import 'package:json_object/json_object.dart';
import 'models/page.dart';
import 'models/workspace.dart';
import 'models/workspaces.dart';

WebSocket ws;

String color;
String user;

String currentPage;
String selectedPage;

HashMap<String, Object> listeners = new HashMap<String, Object>();


List<PageModel> pages = new List<PageModel>();

outputMsg(String msg) {
  print(msg);
//  var output = query('#output');
//  output.text = "${output.text}\n${msg}";
}
//
//class MyList extends JsonObject implements List { 
//  MyList();
//
//  factory MyList.fromString(String jsonString) {
//    return new JsonObject.fromJsonString(jsonString, new MyList());
//  }
//}

void initWebSocket(String url, [int retrySeconds = 2]) {
  var encounteredError = false;
  
  outputMsg("Connecting to Web socket");
  ws = new WebSocket(url);
  
  ws.onOpen.listen((e) {
    outputMsg('Connected');
    DateTime now = new DateTime.now();
    ws.send('alex'+' '+now.toString());
  });
  
  ws.onClose.listen((e) {
    outputMsg('web socket closed, retrying in $retrySeconds seconds');
    if (!encounteredError) {
      new Timer(new Duration(seconds:retrySeconds),
          () => initWebSocket(url, retrySeconds*2));
    }
    encounteredError = true;
  });
  
  ws.onError.listen((e) {
    outputMsg("Error connecting to ws");
    if (!encounteredError) {
      new Timer(new Duration(seconds:retrySeconds),
          () => initWebSocket(url, retrySeconds*2));
    }
    encounteredError = true;
  });
  
  ws.onMessage.listen((MessageEvent e) {
//    var data = parse(e.data);
    var msg = new JsonObject.fromJsonString(e.data);

//    String type = data["type"].toString();
    switch (msg.type) {
      case 'hello':
        ws.send('{"cmd": "getWorkspace"}');
        color = msg.data.color;
        user = msg.data.user;
        
        UListElement ul = query("#user");
        LIElement li = new LIElement();
        li.style.color = color;
        li.text = user;
        ul.append(li);
        
        print("hello " + user);
        break;
      case 'model':
        outputMsg('received model');
        updateModel(msg.objects);
        break;
    }
  });
}

void makeMovable(HtmlElement target, HtmlElement handle) {

  var mouseDownListener = handle.onMouseDown.listen(null);
  mouseDownListener.onData((MouseEvent event) {
    DateTime start = new DateTime.now();
    int initialXOffset = target.offsetLeft - event.pageX;
    int initialYOffset = target.offsetTop - event.pageY;
    
    target.style.transition = 'none';

    var mouseMoveListener = document.onMouseMove.listen((MouseEvent e1) {
      target.style.left = (e1.pageX + initialXOffset).toString() + 'px';
      target.style.top = (e1.pageY + initialYOffset).toString() + 'px';
    });
    
    var mouseUpListener = document.onMouseUp.listen(null);
    mouseUpListener.onData((MouseEvent e2) {
      DateTime now = new DateTime.now();
      if (now.millisecondsSinceEpoch < start.millisecondsSinceEpoch + 100) {
        onSelected(e2);
      } else {
        onMove(e2, e2.pageX + initialXOffset, e2.pageY + initialYOffset);
      }
//      mouseDownListener.cancel();
      mouseUpListener.cancel();
      mouseMoveListener.cancel();
    });

    event.preventDefault();
    
    return false;
  });
}

void updateModel(objects) {
  
  pages.clear();
  
  for (JsonObject obj in objects) {
    String type = obj["type"].toString();

    outputMsg('model ' + type);

    switch(obj["type"]) {
      case "workspace":
        WorkspaceModel w = WorkspaceModel.fromJsonObj(obj);
        print("get workspace: " + w.name);
        break;
      case "page":
        PageModel p = PageModel.fromJsonObj(obj);
        pages.add(p);
        print("get page: " + p.name);
        
        DivElement d = query("#" + p.id);

        // Add to view if not exist
        if (d == null) {
          d = new DivElement();
          Element workspace = query("#workspace");
          workspace.append(d);
          d.style.position = "absolute";
          d.className = "page";
          makeMovable(d, d);
        }

        bool selected = obj["selected"] != null && obj["selected"];

        if (obj["name"] != null)
          d.text = obj["name"];        
        if (obj["offsetTop"] != null)
          d.style.top = obj["offsetTop"].toString() + "px";
        if (obj["offsetLeft"] != null)
          d.style.left = obj["offsetLeft"].toString() + "px";
        if (obj["id"] != null)
          d.id = obj["id"];
        
        d.style.transition = 'none';
        d.style.border = p.selected ? "2px solid " + color : "none";
        
//        d.onClick.
//        forEach((action) {
//          print(action);
//        });
        //d.draggable = true;
        //d.onDragEnd.listen(onDragEnd);        

        break;
    }
  }
  
//  MyList list = new MyList.fromString(objects);
//  
//  for (int i = 0; len(objects[i]); i++) {
//    print(objects[i]);
//  }

//  
//  String type = objects["type"].toString();
//  switch (type) {
//    case 'hello':  
//      ws.send('getWorkspace');
//      ws.send('getPages');
//      print("hellow");
//      break;
//    case 'message':
//      outputMsg('received message ${type}');
//      updateModel(data["data"]);
//      break;
//  }
}

void main() {
  
  initWebSocket('ws://127.0.0.1:8124/ws');
  
  var body = query('body');
  body.onMouseWheel.listen(onEnterPage);
  body.onMouseWheel.listen(onExitPage);
}

void onEnterPage(event) {
  if (event.wheelDeltaY < 0) return;
  
  print('onEnterPage');
  
  String id = selectedPage;
  
  if (id != currentPage) {
    currentPage = id;

    PageModel page = null;
    for (PageModel p in pages) {
      if (p.id == id) {
        page = p;
        break;
      }
    }
    
    DivElement d = query('#' + id);
    d.style.top = '100px';
    d.style.left = '450px';
    d.style.width = '300px';
    d.style.height = '450px';
    d.style.zIndex = '10';
    d.style.transition = 'all 0.4s ease-out';
    
    // Open toolbox
    DivElement toolbox = query("#toolbox");
    toolbox.style.left = '0';
    toolbox.style.transition = 'all 0.8s ease-out';
  }
//}
//  for (PageModel p in pages) {

}
void onExitPage(event) {
  if (event.wheelDeltaY > 0) return;

  print('onExitPage');

  String id = selectedPage;
  
  if (id == currentPage) {
    currentPage = null;

    PageModel page = null;
    for (PageModel p in pages) {
      if (p.id == id) {
        page = p;
        break;
      }
    }

    DivElement d = query('#' + id);
    d.style.top = page.y.toString() + 'px';
    d.style.left = page.x.toString() + 'px';
    d.style.width = '80px';
    d.style.height = '100px';
    d.style.zIndex = '0';
    d.style.transition = 'all 0.4s ease-in';
    
    // Close toolbox
    DivElement toolbox = query("#toolbox");
    toolbox.style.left = '-1500px';
    toolbox.style.transition = 'all 0.8s ease-in';
  }
//}

}

void socketMessage() {
 print('message');
}

void socketOpen() {
  print('open');
}

void onSelected(MouseEvent event) {
  Element elem = query("#" + event.target.id);
  String id = event.target.id;
  
  for (PageModel p in pages) {
    if (p.id == id) {
      selectedPage = p.selected ? null : p.id;
      var jsonData = '{"cmd": "updateWorkspace", "id": "' + p.id + '", "data": {"selected": ' + (!p.selected).toString() + '}}';
      ws.send(jsonData);
    } else if (p.selected) {
      var jsonData = '{"cmd": "updateWorkspace", "id": "' + p.id + '", "data": {"selected": false}}';
      ws.send(jsonData);
    }

  }

}

void onMove(MouseEvent event, int x, int y) {
  print(event);
  
  var jsonData = '{"cmd": "updateWorkspace", "id": "' + event.target.id + '", "data": {"offsetTop": ' + y.toString() + ', "offsetLeft": ' + x.toString() + '}}';
  ws.send(jsonData);
  
  print("onDragEnd: " + event.target.id.toString() + " " + x.toString() + " " + y.toString());
}
