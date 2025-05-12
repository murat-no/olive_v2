import 'dart:convert'; // JSON işlemleri için
import 'package:http/http.dart' as http; // HTTP istekleri için
import 'package:olive_v2/models/login_response.dart'; // Login yanıt modelimiz
import 'package:olive_v2/config/app_config.dart';

// TODO: Backend API'nizin temel URL'sini buraya yazın.
// Örnek: Yerel makinenizde çalışıyorsa 'http://localhost:8080' gibi olabilir.
// Canlı ortamda 'https://api.uygulamanizinadresi.com' gibi olacaktır.
//const String _baseUrl = 'http://localhost:4011'; // BURAYI DÜZENLEYİN!

class AuthService {

  // Login isteği gönderecek metod
  Future<LoginResponse> login(String username, String password) async {
    //final url = Uri.parse('$_baseUrl/api/login'); // Login endpoint'inin tam URL'si
    final url = Uri.parse('$kBaseUrl/api/login'); // kBaseUrl kullanılıyor

    // İstek gövdesi (Backend'in beklediği JSON yapısı)
    final body = jsonEncode({
      'user_name': username,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Gövdenin JSON olduğunu belirtiyoruz
           'Accept': 'application/json', // Yanıtı JSON beklediğimizi belirtiyoruz (isteğe bağlı ama iyi pratik)
        },
        body: body,
      );

      // Yanıtın gövdesini al
      final responseBody = utf8.decode(response.bodyBytes); // Türkçe karakterler için

      // JSON string'ini Map'e dönüştür
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      // JSON'ı LoginResponse modeline dönüştür
      final LoginResponse loginResponse = LoginResponse.fromJson(jsonResponse);

      // Backend'den gelen "error" flag'ini kontrol et
      if (loginResponse.error) {
        // Backend bir hata mesajı döndürmüşse (error: true)
        // Bu genellikle kullanıcı adı/şifre hatası veya backend tarafında iş mantığı hatasıdır.
         print('Backend Hatası: ${loginResponse.message}'); // Loglama
        throw Exception('Giriş başarısız: ${loginResponse.message}'); // Hata mesajını fırlat
      }

      // HTTP status kodunu kontrol et (opsiyonel ama iyi pratik)
      // Backend'in başarılı yanıtta 200 OK döndürdüğünü biliyoruz.
      if (response.statusCode == 200) {
          // Başarılı HTTP yanıtı ve backend error: false
          print('Giriş Başarılı! Token: ${loginResponse.bearertoken?..token}'); // Loglama
          return loginResponse; // Başarılı yanıtı döndür
      } else {
          // HTTP status kodu 200 değilse (örn. 401, 404, 500 gibi)
          // Bu genellikle backend tarafında API'ye ulaşma veya sunucu tarafı hatalarıdır.
          // Backend'in hata yanıtı formatını tam bilmediğimiz için şimdilik
          // response.body veya status kodunu kullanarak genel bir hata fırlatabiliriz.
          print('HTTP Hatası: ${response.statusCode} - ${response.reasonPhrase}'); // Loglama
          print('Yanıt Gövdesi: $responseBody'); // Hata durumunda yanıt gövdesini logla
          throw Exception('API isteği başarısız oldu. Durum Kodu: ${response.statusCode}');
      }

    } catch (e) {
      // Ağ hataları, JSON parse hataları vb.
       print('API Çağrısı Sırasında Hata: $e'); // Loglama
      throw Exception('Bağlantı hatası oluştu: ${e.toString()}'); // Yakalanan hatayı fırlat
    }
  }

  // TODO: İleride diğer kimlik doğrulama/yetkilendirme ile ilgili metodlar eklenebilir
  // Örneğin: Future<bool> checkToken(String token) vb.
}