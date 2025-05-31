// lib/screens/owner_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/owner_store.dart';
import 'package:olive_v2/models/owner.dart';
import 'package:olive_v2/screens/add_edit_owner_screen.dart'; // ✨ YENİ: AddEditOwnerScreen'ı import et ✨

class OwnerListScreen extends StatefulWidget {
  const OwnerListScreen({super.key});

  @override
  _OwnerListScreenState createState() => _OwnerListScreenState();
}

class _OwnerListScreenState extends State<OwnerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late OwnerStore _ownerStore;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _ownerStore.setSearchQuery(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ownerStore = Provider.of<OwnerStore>(context, listen: false);

    if (_ownerStore.owners.isEmpty && !_ownerStore.isLoading) {
       print('DEBUG: OwnerListScreen didChangeDependencies - Liste boş ve yüklenmiyor, veriler çekiliyor.');
       _ownerStore.fetchOwners();
    } else {
       print('DEBUG: OwnerListScreen didChangeDependencies - Liste dolu veya yükleniyor.');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ownerStore.disposeDebounce();
    super.dispose();
  }

  // Yeni Sahip Ekleme Metodu
  void _addNewOwner() async {
     print('DEBUG: Yeni Sahip Ekle butonu tıklandı.');
     final result = await Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => const AddEditOwnerScreen()), // ✨ AddEditOwnerScreen'ı aç ✨
     );
     // AddEditOwnerScreen'dan true dönerse (kaydetme başarılıysa), listeyi yenile
     if (result == true) {
       print('DEBUG: AddEditOwnerScreen\'dan başarılı sonuç döndü, Owner listesi yenileniyor.');
       _ownerStore.fetchOwners(query: _ownerStore.searchQuery, page: _ownerStore.currentPage);
     }
  }

  // Sahip Silme Onayı ve İşlemi
  Future<void> _confirmAndDeleteOwner(String ownerId, String ownerName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sahibi Sil'),
          content: Text('$ownerName adlı sahibi silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      print('DEBUG: Sahip silme onaylandı: ID $ownerId');
      try {
        await _ownerStore.deleteOwner(ownerId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$ownerName başarıyla silindi.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme Başarısız: ${_ownerStore.errorMessage ?? "Bilinmeyen hata."}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahipler Listesi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Yeni Sahip Ekle',
            onPressed: _addNewOwner, // ✨ _addNewOwner metodunu çağır ✨
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Sahip Ara',
                hintText: 'Ad, soyad, telefon veya e-posta ile arama yapın...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_ownerStore.isLoading && _ownerStore.owners.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_ownerStore.errorMessage != null) {
                  return Center(
                    child: Text(
                      'Hata: ${_ownerStore.errorMessage!}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (_ownerStore.owners.isEmpty) {
                  return const Center(child: Text('Kayıtlı sahip bulunamadı.'));
                } else {
                  return RefreshIndicator(
                    onRefresh: () => _ownerStore.fetchOwners(query: _ownerStore.searchQuery, page: 1),
                    child: ListView.builder(
                      itemCount: _ownerStore.owners.length,
                      itemBuilder: (context, index) {
                        final owner = _ownerStore.owners[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          elevation: 2.0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Text(
                                owner.firstName?.isNotEmpty == true ? owner.firstName![0].toUpperCase() : (owner.lastName?.isNotEmpty == true ? owner.lastName![0].toUpperCase() : '?'),
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(owner.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${owner.phone ?? ''}${owner.phone != null && owner.phone!.isNotEmpty && owner.email != null && owner.email!.isNotEmpty ? ' - ' : ''}${owner.email ?? ''}'
                              '${owner.cityDisp != null && owner.cityDisp!.isNotEmpty ? '\n${owner.cityDisp}' : ''}'
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async { // ✨ Düzenle butonu güncellendi ✨
                                    if (owner.id != null && owner.id!.isNotEmpty) {
                                      print('DEBUG: Sahip düzenleme tıklandı: ${owner.fullName}, ID: ${owner.id}');
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AddEditOwnerScreen(ownerToEdit: owner)), // ownerToEdit parametresi ile aç
                                      );
                                      if (result == true) {
                                        print('DEBUG: AddEditOwnerScreen\'dan başarılı sonuç döndü, Owner listesi yenileniyor.');
                                        _ownerStore.fetchOwners(query: _ownerStore.searchQuery, page: _ownerStore.currentPage);
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bu sahip düzenlenemiyor (ID eksik).')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (owner.id != null && owner.id!.isNotEmpty) {
                                      _confirmAndDeleteOwner(owner.id!, owner.fullName);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bu sahip silinemiyor (ID eksik).')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // Sahip detay ekranına gitmek için kullanılabilir (veya doğrudan düzenleme)
                              print('DEBUG: Sahip detay tıklandı: ${owner.fullName}');
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          // Sayfalama (Pagination) Kontrolleri
          Observer(
            builder: (_) {
              if (_ownerStore.owners.isNotEmpty || _ownerStore.isLoading) {
                final totalPages = (_ownerStore.totalRowCount / _ownerStore.rowsPerPage).ceil();
                final displayTotalPages = totalPages > 0 ? totalPages : 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _ownerStore.currentPage > 1 && !_ownerStore.isLoading
                            ? () => _ownerStore.setCurrentPage(_ownerStore.currentPage - 1)
                            : null,
                      ),
                      Text('Sayfa ${_ownerStore.currentPage} / $displayTotalPages'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _ownerStore.currentPage < totalPages && !_ownerStore.isLoading
                            ? () => _ownerStore.setCurrentPage(_ownerStore.currentPage + 1)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: _ownerStore.rowsPerPage,
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 / Sayfa')),
                          DropdownMenuItem(value: 10, child: Text('10 / Sayfa')),
                          DropdownMenuItem(value: 20, child: Text('20 / Sayfa')),
                        ],
                        onChanged: _ownerStore.isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  _ownerStore.setRowsPerPage(value);
                                }
                              },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}