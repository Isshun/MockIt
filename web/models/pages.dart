library model;

import 'page.dart';
import '../views/page.dart';
import 'package:json_object/json_object.dart';

class PagesModel {
  List<PageModel> list = new List<PageModel>();

  void clear() {
    list.clear();
  }
  
  PageModel addfromJsonObj(JsonObject obj) {
    PageModel p = PageModel.fromJsonObj(obj);
    list.add(p);
    return p;
  }
  
  PageView getView(String id) {
    PageModel model = null;
    for (PageModel p in list) {
      if (p.id == id) {
        model = p;
          break;
      }
    }
    
    return new PageView(model);
  }
}