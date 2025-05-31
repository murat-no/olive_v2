// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BaseStore on _BaseStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_BaseStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_BaseStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$totalRowCountAtom =
      Atom(name: '_BaseStore.totalRowCount', context: context);

  @override
  int get totalRowCount {
    _$totalRowCountAtom.reportRead();
    return super.totalRowCount;
  }

  @override
  set totalRowCount(int value) {
    _$totalRowCountAtom.reportWrite(value, super.totalRowCount, () {
      super.totalRowCount = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_BaseStore.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$rowsPerPageAtom =
      Atom(name: '_BaseStore.rowsPerPage', context: context);

  @override
  int get rowsPerPage {
    _$rowsPerPageAtom.reportRead();
    return super.rowsPerPage;
  }

  @override
  set rowsPerPage(int value) {
    _$rowsPerPageAtom.reportWrite(value, super.rowsPerPage, () {
      super.rowsPerPage = value;
    });
  }

  late final _$executeAsyncAction =
      AsyncAction('_BaseStore.execute', context: context);

  @override
  Future<T?> execute<T>(Future<T> Function() callback,
      {String? customErrorMessage,
      ErrorCallback onError = _defaultErrorCallback,
      FinallyCallback onFinally = _defaultFinallyCallback,
      bool showLoading = true,
      bool clearErrorOnStart = true}) {
    return _$executeAsyncAction.run(() => super.execute<T>(callback,
        customErrorMessage: customErrorMessage,
        onError: onError,
        onFinally: onFinally,
        showLoading: showLoading,
        clearErrorOnStart: clearErrorOnStart));
  }

  late final _$_BaseStoreActionController =
      ActionController(name: '_BaseStore', context: context);

  @override
  void setTotalRowCount(int count) {
    final _$actionInfo = _$_BaseStoreActionController.startAction(
        name: '_BaseStore.setTotalRowCount');
    try {
      return super.setTotalRowCount(count);
    } finally {
      _$_BaseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int page) {
    final _$actionInfo = _$_BaseStoreActionController.startAction(
        name: '_BaseStore.setCurrentPage');
    try {
      return super.setCurrentPage(page);
    } finally {
      _$_BaseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRowsPerPage(int rows) {
    final _$actionInfo = _$_BaseStoreActionController.startAction(
        name: '_BaseStore.setRowsPerPage');
    try {
      return super.setRowsPerPage(rows);
    } finally {
      _$_BaseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalRowCount: ${totalRowCount},
currentPage: ${currentPage},
rowsPerPage: ${rowsPerPage}
    ''';
  }
}
