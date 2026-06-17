import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import 'auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  AuthUser? currentUser;
  String? loginError;
  bool isLoading = false;

  Future<void> tryAutoLogin() async {
    final user = await AuthService.restoreSession();
    currentUser = user;
    status =
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    loginError = null;
    notifyListeners();
    try {
      final user = await AuthService.login(email, password);
      currentUser = user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      loginError = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      loginError = 'Unable to connect to the server. Please check your connection.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void forceLogout() {
    currentUser = null;
    status = AuthStatus.unauthenticated;
    loginError = 'Your session has expired. Please sign in again.';
    notifyListeners();
  }
}
