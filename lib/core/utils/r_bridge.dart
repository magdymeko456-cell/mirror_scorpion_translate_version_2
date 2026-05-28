
class R {
  static final dynamic _vars = {};
  
  static dynamic get(String key) => _vars[key];
  static void set(String key, dynamic value) => _vars[key] = value;
  
  // تعريفات افتراضية لتجنب الانهيار
  static dynamic get drawable => _Drawable();
  static dynamic get id => _Id();
}

class _Drawable {
  dynamic operator [](String key) => 0;
  int get ic_close_bubble => 0;
}

class _Id {
  dynamic operator [](String key) => 0;
}

void initializeRVariables() {
  print("R Variables Initialized");
  // هنا يمكن إضافة أي تعريفات يحتاجها التطبيق عند الفتح
}
