// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OwnerStore on _OwnerStore, Store {
  late final _$ownersAtom = Atom(name: '_OwnerStore.owners', context: context);

  @override
  ObservableList<Owner> get owners {
    _$ownersAtom.reportRead();
    return super.owners;
  }

  @override
  set owners(ObservableList<Owner> value) {
    _$ownersAtom.reportWrite(value, super.owners, () {
      super.owners = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_OwnerStore.searchQuery', context: context);

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

  late final _$fetchOwnersAsyncAction =
      AsyncAction('_OwnerStore.fetchOwners', context: context);

  @override
  Future<void> fetchOwners({String? query, int? page, int? rows}) {
    return _$fetchOwnersAsyncAction
        .run(() => super.fetchOwners(query: query, page: page, rows: rows));
  }

  late final _$saveOrUpdateOwnerAsyncAction =
      AsyncAction('_OwnerStore.saveOrUpdateOwner', context: context);

  @override
  Future<Owner?> saveOrUpdateOwner(Owner ownerData) {
    return _$saveOrUpdateOwnerAsyncAction
        .run(() => super.saveOrUpdateOwner(ownerData));
  }

  late final _$deleteOwnerAsyncAction =
      AsyncAction('_OwnerStore.deleteOwner', context: context);

  @override
  Future<bool> deleteOwner(String ownerId) {
    return _$deleteOwnerAsyncAction.run(() => super.deleteOwner(ownerId));
  }

  late final _$_OwnerStoreActionController =
      ActionController(name: '_OwnerStore', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_OwnerStoreActionController.startAction(
        name: '_OwnerStore.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_OwnerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int page) {
    final _$actionInfo = _$_OwnerStoreActionController.startAction(
        name: '_OwnerStore.setCurrentPage');
    try {
      return super.setCurrentPage(page);
    } finally {
      _$_OwnerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRowsPerPage(int rows) {
    final _$actionInfo = _$_OwnerStoreActionController.startAction(
        name: '_OwnerStore.setRowsPerPage');
    try {
      return super.setRowsPerPage(rows);
    } finally {
      _$_OwnerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void disposeDebounce() {
    final _$actionInfo = _$_OwnerStoreActionController.startAction(
        name: '_OwnerStore.disposeDebounce');
    try {
      return super.disposeDebounce();
    } finally {
      _$_OwnerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
owners: ${owners},
searchQuery: ${searchQuery}
    ''';
  }
}
