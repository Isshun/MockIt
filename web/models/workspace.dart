library model;

import 'package:polymer/polymer.dart';
import 'package:uuid/uuid.dart';
import 'package:json_object/json_object.dart';

//final appModel = new AppModel._();

class WorkspaceModel extends JsonObject {
  @observable bool editing = false;
  @observable String value = '';
  bool get applyAuthorStyles => true;
  
  var uuid = new Uuid();
  
  String _name;
  int _x;
  int _y;
  String _id;
  
  String get getId => _id;
  
  void set name(String value) { _name = value; }
  String get name => _name;
  
  //InputElement get _editBox => getShadowRoot("editable-label").query('#edit');

  static WorkspaceModel fromJsonObj(JsonObject json) {
    WorkspaceModel w = new WorkspaceModel();
    w.name = json["name"];
    return w;
  }
  
  WorkspaceModel() {
    _id = uuid.v4();
  }
  
  void setPosition(int x, int y) {
    _x = x;
    _y = y;
  }

  void setName(String value) {
    editing = true;
    _name = value;
  }
}