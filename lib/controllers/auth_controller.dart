import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _usersKey = 'users_list';
  static const String _currentUserKey = 'current_user_id';

  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  // Expose the reactive user so other controllers can listen
  Rxn<UserModel> get currentUserRx => _currentUser;
  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final currentId = _storage.read<String?>(_currentUserKey);
    final stored = _storage.read<List<dynamic>>(_usersKey);
    if (stored != null && currentId != null) {
      final users = stored.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
      for (var u in users) {
        if (u.id == currentId) {
          _currentUser.value = u;
          break;
        }
      }
    }
  }

  List<UserModel> _allUsersFromStorage() {
    final stored = _storage.read<List<dynamic>>(_usersKey) ?? <dynamic>[];
    return stored
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _persistUsers(List<UserModel> users) {
    final json = users.map((u) => u.toJson()).toList();
    _storage.write(_usersKey, json);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register({required String username, required String password, String? displayName}) async {
    final users = _allUsersFromStorage();
    final exists = users.any((u) => u.username.toLowerCase() == username.toLowerCase());
    if (exists) return false; // username taken

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      id: id,
      username: username,
      displayName: displayName ?? username,
      passwordHash: _hashPassword(password),
    );
    users.add(user);
    _persistUsers(users);
    // set current user
    _storage.write(_currentUserKey, user.id);
    _currentUser.value = user;
    return true;
  }

  Future<bool> login({required String username, required String password}) async {
    final users = _allUsersFromStorage();
    final pwdHash = _hashPassword(password);
    UserModel? found;
    for (var u in users) {
      if (u.username.toLowerCase() == username.toLowerCase() && u.passwordHash == pwdHash) {
        found = u;
        break;
      }
    }
    if (found == null) return false;
    _currentUser.value = found;
    _storage.write(_currentUserKey, found.id);
    return true;
  }

  void logout() {
    _currentUser.value = null;
    _storage.remove(_currentUserKey);
  }
}

