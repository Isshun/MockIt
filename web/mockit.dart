import 'dart:html';
import 'dart:collection';
import 'dart:async';
import 'package:json_object/json_object.dart';
import 'model.dart';
import 'models/page.dart';
import 'models/user.dart';
import 'views/workspace.dart';
import 'models/workspace.dart';
import 'models/workspaces.dart';

void main() {
  
  UserModel user = new UserModel();
  
  Model ws = new Model(user);
  
  Workspace workspace = new Workspace(ws, user);
}

