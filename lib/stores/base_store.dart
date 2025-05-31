// lib/stores/base_store.dart

import 'package:mobx/mobx.dart';

part 'base_store.g.dart';

// Callback fonksiyonlar için typedef tanımları
typedef ErrorCallback = void Function(String error);
typedef FinallyCallback = void Function();

// ✨ ÖNEMLİ DEĞİŞİKLİK: Varsayılan boş callback'ler artık sınıfın dışında, dosya seviyesinde tanımlı ✨
void _defaultErrorCallback(String error) {
  // print('Default error callback: $error'); // Debug için bırakılabilir
}
void _defaultFinallyCallback() {
  // print('Default finally callback'); // Debug için bırakılabilir
}

abstract class BaseStore = _BaseStore with _$BaseStore;

abstract class _BaseStore with Store {
  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int totalRowCount = 0;

  @observable
  int currentPage = 1;

  @observable
  int rowsPerPage = 10;

  @action
  Future<T?> execute<T>(Future<T> Function() callback, {
    String? customErrorMessage,
    // onError ve onFinally'a varsayılan olarak dışarıdaki fonksiyonları atıyoruz
    ErrorCallback onError = _defaultErrorCallback,
    FinallyCallback onFinally = _defaultFinallyCallback,
    bool showLoading = true,
    bool clearErrorOnStart = true,
  }) async {
    runInAction(() {
      if (showLoading) {
        isLoading = true;
      }
      if (clearErrorOnStart) {
        errorMessage = null;
      }
    });

    try {
      final result = await callback();
      runInAction(() {
        errorMessage = null;
      });
      return result;
    } catch (e) {
      final String errorMsg = customErrorMessage ?? e.toString();
      runInAction(() {
        errorMessage = errorMsg;
      });
      print('ERROR (BaseStore.execute): $errorMsg');
      onError(errorMsg); // Artık null-safe çağrıya gerek yok, varsayılan fonksiyon çağrılacak
      return null;
    } finally {
      runInAction(() {
        if (showLoading) {
          isLoading = false;
        }
      });
      onFinally(); // Artık null-safe çağrıya gerek yok, varsayılan fonksiyon çağrılacak
    }
  }

  @action
  void setTotalRowCount(int count) => totalRowCount = count;

  @action
  void setCurrentPage(int page) => currentPage = page;

  @action
  void setRowsPerPage(int rows) => rowsPerPage = rows;
}