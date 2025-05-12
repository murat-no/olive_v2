import 'package:mobx/mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:olive_v2/services/auth_service.dart';
import 'package:olive_v2/models/login_response.dart';
//import 'package:olive_v2/models/token.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // ✨ Yeni eklenen alan: Aktif kullanıcının adı ✨
  @observable
  String? currentUserName; // Başlangıçta null

  // Login aksiyonu
  @action
  Future<LoginResponse> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _authService.login(username, password);

      if (response.bearertoken?.token != null) {
        print('DEBUG: Token depolamaya yazılıyor...');
        await _secureStorage.write(key: 'jwt_token', value: response.bearertoken!.token!);
        print('DEBUG: Token başarıyla yazıldı.');

        // ✨ Başarılı login sonrası kullanıcı adını observable alana kaydet ✨
        currentUserName = response.userName;
        print('DEBUG: currentUserName set edildi: $currentUserName');

      } else {
         print('DEBUG: Login başarılı ancak token null geldi.');
         // Token gelmezse kullanıcı adını da null yapalım tutarlı olması için
         currentUserName = null;
      }

      isLoading = false;
      return response;

    } catch (e) {
      errorMessage = e.toString();
      print('DEBUG: Login Aksiyonunda Hata Yakalandı: $errorMessage');
      isLoading = false;
      // Hata durumunda kullanıcı adını temizle
      currentUserName = null;
      rethrow;
    }
  }

  // Kayıtlı tokenı okuma metodu
  Future<String?> getStoredToken() async {
    print('DEBUG: Saklı token okunuyor...');
    final token = await _secureStorage.read(key: 'jwt_token');
    print('DEBUG: Okunan token değeri: $token');
     // TODO: Burada token validasyonu sonrası kullanıcı bilgisini de çekip currentUserName'i set edebiliriz.
     // Şimdilik sadece token var mı diye bakıyoruz.
    return token;
  }

  // Logout aksiyonu - saklanan tokenı siler ve kullanıcı adını temizler
   @action
   Future<void> logout() async {
     print('DEBUG: Token siliniyor...');
     await _secureStorage.delete(key: 'jwt_token');
     print('DEBUG: Token silindi.');
     // ✨ Logout olunca kullanıcı adını temizle ✨
     currentUserName = null;
   }
}