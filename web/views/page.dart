import 'dart:html';

import 'package:uuid/uuid.dart';

import '../models/page.dart';
import '../views/page.dart';


class PageView {
  
  int BORDER_SIZE = 20;
  
  String      _id;
  String get id => _id;
  
  var uuid = new Uuid();
  
  List<HtmlElement> _items = new List<HtmlElement>();
  String    _selectedItemId;
  
  var keyboardListener;
  
  DivElement _toolbox;
  
  PageModel   _model;
  
  bool _modifier_ctrl = false;
  bool _modifier_caps = false;
  bool _modifier_alt = false;
  bool _modifier_resize = false;
  
  PageView(PageModel model) {
    _model = model;
    _id = model.id;
  }
  
  void onCreate(parent) {
    
    keyboardListener = document.onKeyDown.listen((KeyboardEvent event) {
      // Ctrl
      if (event.keyCode == 17) {
        _modifier_ctrl = true;
      }
      // Caps
      if (event.keyCode == 16) {
        _modifier_caps = true;
      }
      // Alt
      if (event.keyCode == 91) {
        _modifier_alt = true;
      }  
    });
    
    keyboardListener = document.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == 27) {
        parent.onPageClosed();
      }
      // Ctrl
      if (event.keyCode == 17) {
        _modifier_ctrl = false;
      }
      // Caps
      if (event.keyCode == 16) {
        _modifier_caps = false;
      }
      // Alt
      if (event.keyCode == 91) {
        _modifier_alt = false;
      }
    });
    
    // Open page
    DivElement d = query('#' + _id);
    d.style.top = '100px';
    d.style.left = '450px';
    d.style.width = '300px';
    d.style.height = '450px';
    d.style.zIndex = '10';
    d.style.transition = 'all 0.4s ease-out';
    
    // Open toolbox
    _toolbox = query("#toolbox");
    _toolbox.style.left = '0';
    _toolbox.style.transition = 'all 0.8s ease-out';
    int z = 1;
    _toolbox.children.forEach((HtmlElement item) {
      
      // Generate uuid
      item.id = uuid.v1();
      
      item.style.zoom = "1";
      
      // Push in items list
      _items.add(item);
      
      // Click / Move
      makeMovable(item, item);

      // Index
      item.style.zIndex = (z++).toString();
      item.onMouseWheel.listen((MouseEvent event) {
        if (_modifier_alt) {
          onItemLevelChange(item, event.wheelDeltaY > 0 ? 1 : -1); 
        } else {
          onItemZoomChange(item, event.wheelDeltaY > 0 ? 0.2 : -0.2);
        }
      });
    });
    
  }
  
  void onDestroy(parent) {
  
    keyboardListener.cancel();
    
    // Close page
    DivElement d = query('#' + _id);
    d.style.top = _model.y.toString() + 'px';
    d.style.left = _model.x.toString() + 'px';
    d.style.width = '80px';
    d.style.height = '100px';
    d.style.zIndex = '0';
    d.style.transition = 'all 0.4s ease-in';
    
    // Close toolbox
    DivElement toolbox = query("#toolbox");
    toolbox.style.left = '-1500px';
    toolbox.style.transition = 'all 0.8s ease-in';
  }
  
  void makeMovable(HtmlElement target, HtmlElement handle) {
  
    var mouseDownListener = handle.onMouseDown.listen(null);
    mouseDownListener.onData((MouseEvent event) {
      
      _modifier_resize = false;

      if (_selectedItemId != event.target.id) {
        onItemSelected(event);
      }
      // Check border
      else {
        if (event.pageX - target.offsetLeft > target.width - BORDER_SIZE) {
          _modifier_resize = true;
        }
      }

      int initialXOffset = target.offsetLeft - event.pageX;
      int initialYOffset = target.offsetTop - event.pageY;
        
      var mouseMoveListener = document.onMouseMove.listen((MouseEvent e1) {
        if (_modifier_resize) {
          target.style.width = (e1.pageX - target.offsetLeft).toString() + 'px';
          target.style.maxWidth = (e1.pageX - target.offsetLeft).toString() + 'px';
          target.style.height = (e1.pageY - target.offsetTop).toString() + 'px';
          target.style.maxHeight = (e1.pageY - target.offsetTop).toString() + 'px';
        }
        else {
          target.style.left = (e1.pageX + initialXOffset).toString() + 'px';
          target.style.top = (e1.pageY + initialYOffset).toString() + 'px';
        }
      });
      
      var mouseUpListener = document.onMouseUp.listen(null);
      mouseUpListener.onData((MouseEvent e2) {
        int distance = abs(event.pageX - e2.pageX) + abs(event.pageY - e2.pageY);
        if (distance > 10) {
          onItemMove(e2, e2.pageX + initialXOffset, e2.pageY + initialYOffset);
        }
        mouseUpListener.cancel();
        mouseMoveListener.cancel();
      });
  
      event.preventDefault();
      
      return false;
    });
  }
  
  int abs(int i) {
    return i < 0 ? i * -1 : 1;
  }
  
  void onItemLevelChange(HtmlElement item, int change) {
    String newIndex = (int.parse(item.style.zIndex) + change).toString();
    _toolbox.children.forEach((HtmlElement e) {
      if (e.style.zIndex == newIndex)
        e.style.zIndex = item.style.zIndex;
    });
    item.style.zIndex = newIndex;
  }
  
  void onItemZoomChange(HtmlElement item, double change) {
    double zoom = double.parse(item.style.zoom) + change;
    item.style.zoom = zoom.toString();
    item.style.left = (item.x * (1+(1-zoom))).toString() + "px";
    item.style.top = (item.y * (1+(1-zoom))).toString() + "px";
  }
  
  void onItemSelected(MouseEvent event) {
    _selectedItemId = event.target.id;

    for (HtmlElement item in _items) {
      item.style.border = "none";
//      item.style.borderTop = "none";
//      item.style.borderRight = "none";
//      item.style.borderLeft = "none";
//      if (item.id == _selectedItem) {
//        _selectedPageId = p.selected ? null : p.id;
//        var jsonData = '{"cmd": "updatePage", "id": "' + _id + '", "data": {"selected": ' + (!p.selected).toString() + '}}';
//        _ws.send(jsonData);
//      } else if (p.selected) {
//        var jsonData = '{"cmd": "updatePage", "id": "' + _id + '", "data": {"selected": false}}';
//        _ws.send(jsonData);
//      }
    }
    
    for (HtmlElement item in _items) {
      if (item.id == _selectedItemId)
        item.style.border = "2px solid blue";
//        item.style.borderBottom = "2px solid darkblue";
//        item.style.borderTop = "2px solid darkblue";
//        item.style.borderRight = "2px solid grey";
//        item.style.borderLeft = "2px solid grey";
    }
  }
  
  void onItemMove(MouseEvent event, int x, int y) {
  }
}

