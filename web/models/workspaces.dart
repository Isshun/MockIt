library model;

import 'package:polymer/polymer.dart';
import 'workspace.dart';

final appModel = new AppModel._();

class WorkspacesModel extends ObservableBase {
  @observable List<WorkspaceModel> models = null;
  
  WorkspacesModel() {
    models = new List<WorkspaceModel>();
    
    for(int i = 0; i < 3; i++) {
      WorkspaceModel m = new WorkspaceModel();
      StringBuffer sb = new StringBuffer();
      m.setName("page " + i.toString());
      m.setPosition(100 * i, 100 * i);
      models.add(m);
    }
  }
  
}