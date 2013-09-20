library model;

import 'package:json_object/json_object.dart';

class PageModel extends JsonObject {
  
  String _name;
  String get name => _name;
  void set name(String value) { _name = value; }
  
  String _id;
  String get id => _id;
  void set id(String value) { _id = value; }
  
  bool _selected;
  bool get selected => _selected;
  void set selected(bool value) { _selected = value; }
  
  int _x;
  int get x => _x;
  void set x(int value) { _x = value; }

  int _y;
  int get y => _y;
  void set y(int value) { _y = value; }

  static PageModel fromJsonObj(JsonObject json) {
    PageModel m = new PageModel();
    m.name = json["name"];
    m.id = json["id"];
    m.x = json["offsetLeft"];
    m.y = json["offsetTop"];
    m.selected = json["selected"] != null && json["selected"];
    return m;
  }

}