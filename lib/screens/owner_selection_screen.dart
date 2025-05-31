// lib/screens/owner_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/owner_store.dart'; // OwnerStore'u import et
import 'package:olive_v2/models/owner.dart'; // Owner modelini import et

class OwnerSelectionScreen extends StatefulWidget {
  const OwnerSelectionScreen({super.key});

  @override
  _OwnerSelectionScreenState createState() => _OwnerSelectionScreenState();
}

class _OwnerSelectionScreenState extends State<OwnerSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  late OwnerStore _ownerStore;

  @override
  void initState() {
    super.initState();
    // Arama metin alanındaki değişiklikleri dinle ve store'a ilet
    _searchController.addListener(() {
      _ownerStore.setSearchQuery(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ownerStore = Provider.of<OwnerStore>(context, listen: false);

    // Ekran ilk yüklendiğinde sahip listesini çek
    if (_ownerStore.owners.isEmpty && !_ownerStore.isLoading) {
       print('DEBUG: OwnerSelectionScreen didChangeDependencies - Liste boş ve yüklenmiyor, veriler çekiliyor.');
       _ownerStore.fetchOwners();
    } else {
       print('DEBUG: OwnerSelectionScreen didChangeDependencies - Liste dolu veya yükleniyor.');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ownerStore.disposeDebounce(); // Debounce timer'ını temizle
    super.dispose();
  }

  // Yeni sahip ekleme (isteğe bağlı, ayrı bir ekranda olabilir)
  void _addNewOwner() async {
    // TODO: Yeni sahip ekleme ekranına yönlendirme
    print('DEBUG: Yeni Sahip Ekle butonu tıklandı. Sahip Ekleme ekranı entegrasyonu yapılacak.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni sahip ekleme özelliği yakında eklenecek.')),
    );
    // Eğer bir AddEditOwnerScreen oluşturursak:
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AddEditOwnerScreen()),
    // );
    // if (result == true) {
    //   _ownerStore.fetchOwners(); // Liste yenile
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahip Seç'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Yeni Sahip Ekle',
            onPressed: _addNewOwner,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Çubuğu
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

          // Yükleniyor, Hata veya Liste Gösterimi
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
                  return RefreshIndicator( // Yenileme için RefreshIndicator
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
                            title: Text(owner.fullName, style: const TextStyle(fontWeight: FontWeight.bold)), // fullName getter'ı kullanıldı
                            subtitle: Text(
                              '${owner.phone ?? ''}${owner.phone != null && owner.phone!.isNotEmpty && owner.email != null && owner.email!.isNotEmpty ? ' - ' : ''}${owner.email ?? ''}'
                              '${owner.cityDisp != null && owner.cityDisp!.isNotEmpty ? '\n${owner.cityDisp}' : ''}'
                            ),
                            onTap: () {
                              // Sahip seçildiğinde, seçilen Owner objesini geri döndür
                              print('DEBUG: Sahip seçildi: ${owner.fullName}, ID: ${owner.id}');
                              Navigator.pop(context, owner);
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