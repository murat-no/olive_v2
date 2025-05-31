import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:olive_v2/stores/animal_store.dart';
import 'package:olive_v2/screens/add_edit_animal_screen.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late AnimalStore _animalStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animalStore = Provider.of<AnimalStore>(context, listen: false);

    if (_animalStore.animals.isEmpty && !_animalStore.isLoading) {
      print('DEBUG: AnimalListScreen didChangeDependencies - Liste boş ve yüklenmiyor, veriler çekiliyor.');
      _animalStore.fetchAnimals();
    } else {
      print('DEBUG: AnimalListScreen didChangeDependencies - Liste dolu veya yükleniyor.');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _animalStore.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animalStore.disposeDebounce(); // AnimalStore'daki debounce timer'ı iptal et
    super.dispose();
  }

  void _addNewAnimal() async {
    print('DEBUG: Yeni Hayvan Ekle butonu tıklandı.');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditAnimalScreen(),
      ),
    );

    if (result == true) {
      print('DEBUG: AddEditAnimalScreen\'dan başarılı sonuç döndü, liste yenileniyor.');
      _animalStore.fetchAnimals(query: _animalStore.searchQuery, page: _animalStore.currentPage);
    }
  }

  // GÜNCELLENMİŞ: Hayvan Silme Onayı ve İşlemi
  Future<void> _confirmAndDeleteAnimal(String animalId, String animalName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hayvanı Sil'),
          content: Text('$animalName adlı hayvanı silmek istediğinizden emin misiniz?'),
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
      print('DEBUG: Hayvan silme onaylandı: ID $animalId');
      try {
        await _animalStore.deleteAnimal(animalId); // Store'daki deleteAnimal aksiyonunu çağır
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$animalName başarıyla silindi.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme Başarısız: ${_animalStore.errorMessage ?? "Bilinmeyen hata."}'),
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
        title: const Text('Hayvan Listesi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Hayvan Ekle',
            onPressed: _addNewAnimal,
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
                labelText: 'Hayvan Ara',
                hintText: 'İsme, sahibe veya diğer alanlara göre arama yapın...',
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
                if (_animalStore.isLoading && _animalStore.animals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_animalStore.errorMessage != null) {
                  return Center(
                    child: Text(
                      'Hata: ${_animalStore.errorMessage!}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (_animalStore.animals.isEmpty) {
                  return const Center(child: Text('Kayıtlı hayvan bulunamadı.'));
                } else {
                  return RefreshIndicator(
                    onRefresh: () => _animalStore.fetchAnimals(query: _animalStore.searchQuery, page: 1),
                    child: ListView.builder(
                      itemCount: _animalStore.animals.length,
                      itemBuilder: (context, index) {
                        final animal = _animalStore.animals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          elevation: 2.0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Text(
                                animal.name?.isNotEmpty == true ? animal.name![0].toUpperCase() : '?',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(animal.name ?? 'İsimsiz Hayvan', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                               '${animal.family ?? ''} - ${animal.race ?? ''} - ${animal.breed ?? ''}'
                               '${animal.owner != null && animal.owner!.isNotEmpty ? '\nSahip: ${animal.owner!}' : ''}'
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    if (animal.id != null && animal.id!.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditAnimalScreen(animalToEdit: animal),
                                        ),
                                      ).then((result) {
                                        if (result == true) {
                                          _animalStore.fetchAnimals(query: _animalStore.searchQuery, page: _animalStore.currentPage);
                                        }
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bu hayvan düzenlenemiyor (ID eksik).')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (animal.id != null && animal.id!.isNotEmpty) {
                                      _confirmAndDeleteAnimal(animal.id!, animal.name ?? 'Bu Hayvan');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bu hayvan silinemiyor (ID eksik).')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // Ana tıklama olayına ne olacağı artık trailing button'lar tarafından yönetilebilir.
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
              if (_animalStore.animals.isNotEmpty || _animalStore.isLoading) {
                final totalPages = (_animalStore.totalRowCount / _animalStore.rowsPerPage).ceil();
                final displayTotalPages = totalPages > 0 ? totalPages : 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _animalStore.currentPage > 1 && !_animalStore.isLoading
                            ? () => _animalStore.setCurrentPage(_animalStore.currentPage - 1)
                            : null,
                      ),
                      Text('Sayfa ${_animalStore.currentPage} / $displayTotalPages'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _animalStore.currentPage < totalPages && !_animalStore.isLoading
                            ? () => _animalStore.setCurrentPage(_animalStore.currentPage + 1)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: _animalStore.rowsPerPage,
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 / Sayfa')),
                          DropdownMenuItem(value: 10, child: Text('10 / Sayfa')),
                          DropdownMenuItem(value: 20, child: Text('20 / Sayfa')),
                        ],
                        onChanged: _animalStore.isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  _animalStore.setRowsPerPage(value);
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