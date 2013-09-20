import '../models/page.dart';
import '../views/page.dart';


class PageView {
  
  String      _id;
  String get id => _id;
  
  PageModel   _model;
  
  PageView(PageModel model) {
    _model = model;
    _id = model.id;
  }
  
}

