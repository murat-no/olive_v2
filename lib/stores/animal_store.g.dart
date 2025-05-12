// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AnimalStore on _AnimalStore, Store {
  late final _$animalsAtom =
      Atom(name: '_AnimalStore.animals', context: context);

  @override
  ObservableList<Animal> get animals {
    _$animalsAtom.reportRead();
    return super.animals;
  }

  @override
  set animals(ObservableList<Animal> value) {
    _$animalsAtom.reportWrite(value, super.animals, () {
      super.animals = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AnimalStore.isLoading', context: context);

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
      Atom(name: '_AnimalStore.errorMessage', context: context);

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

  late final _$searchQueryAtom =
      Atom(name: '_AnimalStore.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$totalRowCountAtom =
      Atom(name: '_AnimalStore.totalRowCount', context: context);

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
      Atom(name: '_AnimalStore.currentPage', context: context);

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
      Atom(name: '_AnimalStore.rowsPerPage', context: context);

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

  late final _$fetchAnimalsAsyncAction =
      AsyncAction('_AnimalStore.fetchAnimals', context: context);

  @override
  Future<void> fetchAnimals({String? query, int? page, int? rows}) {
    return _$fetchAnimalsAsyncAction
        .run(() => super.fetchAnimals(query: query, page: page, rows: rows));
  }

  @override
  String toString() {
    return '''
animals: ${animals},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
totalRowCount: ${totalRowCount},
currentPage: ${currentPage},
rowsPerPage: ${rowsPerPage}
    ''';
  }
}
