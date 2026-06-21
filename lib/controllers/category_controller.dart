import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _baseKey = 'categories';

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  String _keyForUser(String? userId) => '${_baseKey}_${userId ?? "public"}';

  void loadCategories([String? userId]) {
    final key = _keyForUser(userId);
    final stored = _storage.read<List<dynamic>>(key);
    if (stored != null) {
      categories.value = stored
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      // initialize defaults
      categories.value = _defaultCategories();
      _persistCategories(userId);
    }
  }

  void _persistCategories(String? userId) {
    final key = _keyForUser(userId);
    final json = categories.map((c) => c.toJson()).toList();
    _storage.write(key, json);
  }

  List<CategoryModel> _defaultCategories() {
    // simple defaults (icons are MaterialIcons codePoints)
    return [
      CategoryModel(id: 'food', name: 'Food', iconCodePoint: 0xe56c, colorValue: 0xFFFF8A65, isIncome: false),
      CategoryModel(id: 'shopping', name: 'Shopping', iconCodePoint: 0xe8cc, colorValue: 0xFFBA68C8, isIncome: false),
      CategoryModel(id: 'salary', name: 'Salary', iconCodePoint: 0xe227, colorValue: 0xFF66BB6A, isIncome: true),
      CategoryModel(id: 'transport', name: 'Transport', iconCodePoint: 0xe530, colorValue: 0xFF42A5F5, isIncome: false),
      CategoryModel(id: 'other', name: 'Other', iconCodePoint: 0xe88a, colorValue: 0xFF90A4AE, isIncome: false),
    ];
  }

  void addCategory(CategoryModel cat, [String? userId]) {
    categories.add(cat);
    _persistCategories(userId);
  }

  void removeCategory(String id, [String? userId]) {
    categories.removeWhere((c) => c.id == id);
    _persistCategories(userId);
  }

  void updateCategory(CategoryModel cat, [String? userId]) {
    final idx = categories.indexWhere((c) => c.id == cat.id);
    if (idx >= 0) {
      categories[idx] = cat;
      _persistCategories(userId);
    }
  }
}

