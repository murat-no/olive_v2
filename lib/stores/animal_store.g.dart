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

  late final _$fetchAnimalsAsyncAction =
      AsyncAction('_AnimalStore.fetchAnimals', context: context);

  @override
  Future<void> fetchAnimals({String? query, int? page, int? rows}) {
    return _$fetchAnimalsAsyncAction
        .run(() => super.fetchAnimals(query: query, page: page, rows: rows));
  }

  late final _$deleteAnimalAsyncAction =
      AsyncAction('_AnimalStore.deleteAnimal', context: context);

  @override
  Future<bool> deleteAnimal(String animalId) {
    return _$deleteAnimalAsyncAction.run(() => super.deleteAnimal(animalId));
  }

  late final _$_AnimalStoreActionController =
      ActionController(name: '_AnimalStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_AnimalStoreActionController.startAction(
        name: '_AnimalStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_AnimalStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int page) {
    final _$actionInfo = _$_AnimalStoreActionController.startAction(
        name: '_AnimalStore.setCurrentPage');
    try {
      return super.setCurrentPage(page);
    } finally {
      _$_AnimalStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRowsPerPage(int rows) {
    final _$actionInfo = _$_AnimalStoreActionController.startAction(
        name: '_AnimalStore.setRowsPerPage');
    try {
      return super.setRowsPerPage(rows);
    } finally {
      _$_AnimalStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disposeDebounce() {
    final _$actionInfo = _$_AnimalStoreActionController.startAction(
        name: '_AnimalStore.disposeDebounce');
    try {
      return super.disposeDebounce();
    } finally {
      _$_AnimalStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
animals: ${animals},
searchQuery: ${searchQuery}
    ''';
  }
}
