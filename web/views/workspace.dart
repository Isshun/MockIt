import 'dart:html';
import 'dart:collection';
import 'dart:async';
import 'dart:math' as math;
import 'package:json_object/json_object.dart';
import '../model.dart';
import '../models/page.dart';
import '../views/page.dart';
import '../models/user.dart';
import '../models/pages.dart';
import '../models/workspace.dart';
import '../models/workspaces.dart';

class Workspace {
    
  PageView    _page;
  String      _selectedPageId;
    
  Model       _ws;
  UserModel   _user;
  PagesModel  _pages;

  Workspace(ws, user) {
    
    _ws = ws;
    _ws.setOnUpdateListener(onUpdate);

    _user = user;
    
    _pages = new PagesModel();
        
//    
//    document.onMouseWheel.listen((MouseEvent event) {
//      // Wheel up
//      if (event.wheelDeltaY > 0) {
//        if (_page == null && _selectedPageId != null) {
//          onPageOpened();
//        }
//      }
//      // Wheel down
//      else {
//        if (_page != null && _selectedPageId != null && _selectedPageId == _page.id) {
//          onPageClosed();
//        }
//      }
//    });
    
    document.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == 32) {
        if (_page == null && _selectedPageId != null) {
          onPageOpened();
        }
      }
    });
  }
  
  void onPageOpened() {
    print('onCreate page');
    _page = _pages.getView(_selectedPageId);
    _page.onCreate(this);
  }
  
  void onPageClosed() {
    print('onPageClosed');
    _page.onDestroy(this);
    _page = null;
  }
  
  outputMsg(String msg) {
    print(msg);
  }
  
  void makeMovable(HtmlElement target, HtmlElement handle) {
  
    var mouseDownListener = handle.onMouseDown.listen(null);
    mouseDownListener.onData((MouseEvent event) {
      if (_page != null) return true;
      
      int initialXOffset = target.offsetLeft - event.pageX;
      int initialYOffset = target.offsetTop - event.pageY;
      
      target.style.transition = 'none';
  
      var mouseMoveListener = document.onMouseMove.listen((MouseEvent e1) {
        target.style.left = (e1.pageX + initialXOffset).toString() + 'px';
        target.style.top = (e1.pageY + initialYOffset).toString() + 'px';
      });
      
      var mouseUpListener = document.onMouseUp.listen(null);
      mouseUpListener.onData((MouseEvent e2) {
        int distance = abs(event.pageX - e2.pageX) + abs(event.pageY - e2.pageY);
        if (distance < 10) {
          onSelected(e2);
        } else {
          onMove(e2, e2.pageX + initialXOffset, e2.pageY + initialYOffset);
        }
        mouseUpListener.cancel();
        mouseMoveListener.cancel();
      });
  
      event.preventDefault();
      
      return false;
    });
  }
  
  void onUpdate(objects) {
    
    _pages.clear();
    
    for (JsonObject obj in objects) {
      String type = obj["type"].toString();
  
      outputMsg('model ' + type);
  
      switch(obj["type"]) {
        case "workspace":
          WorkspaceModel w = WorkspaceModel.fromJsonObj(obj);
          print("get workspace: " + w.name);
          break;
        case "page":
          PageModel p = _pages.addfromJsonObj(obj);
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
          d.style.border = p.selected ? "2px solid " + _user.color : "none";
  
          break;
      }
    }
  }
  
  
  void onSelected(MouseEvent event) {
    Element elem = query("#" + event.target.id);
    String id = event.target.id;
    
    for (PageModel p in _pages.list) {
      if (p.id == id) {
        _selectedPageId = p.selected ? null : p.id;
        var jsonData = '{"cmd": "updateWorkspace", "id": "' + p.id + '", "data": {"selected": ' + (!p.selected).toString() + '}}';
        _ws.send(jsonData);
      } else if (p.selected) {
        var jsonData = '{"cmd": "updateWorkspace", "id": "' + p.id + '", "data": {"selected": false}}';
        _ws.send(jsonData);
      }
    }
  }
  
  void onMove(MouseEvent event, int x, int y) {
    print(event);
    
    var jsonData = '{"cmd": "updateWorkspace", "id": "' + event.target.id + '", "data": {"offsetTop": ' + y.toString() + ', "offsetLeft": ' + x.toString() + '}}';
    _ws.send(jsonData);
    
    print("onDragEnd: " + event.target.id.toString() + " " + x.toString() + " " + y.toString());
  }
  
  int abs(int i) {
    return i < 0 ? i * -1 : i * 1;
  }
}

