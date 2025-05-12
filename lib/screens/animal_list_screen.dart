import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Store'u okumak için
import 'package:flutter_mobx/flutter_mobx.dart'; // Observer için
import 'package:olive_v2/stores/animal_store.dart'; // AnimalStore'u import et
//import 'package:olive_v2/models/animal.dart'; // Animal modelini import et
// import 'package:olive_v2/screens/animal_detail_screen.dart'; // Artık bu ekran YOK, importu kaldırdık
import 'package:olive_v2/screens/add_edit_animal_screen.dart'; // Add/Edit ekranını import et


class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  // Arama metin alanının kontrolcüsü
  final TextEditingController _searchController = TextEditingController();
  // AnimalStore instance'ı
  late AnimalStore _animalStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AnimalStore instance'ını al
    // listen: false çünkü build metodunda sürekli dinlemeyeceğiz, sadece instance lazım
    _animalStore = Provider.of<AnimalStore>(context, listen: false);

    // Ekran ilk yüklendiğinde hayvan listesini çek (arama sorgusu boşken)
    // Eğer liste zaten doluysa tekrar çekme (performance için)
    if (_animalStore.animals.isEmpty) {
       print('DEBUG: AnimalListScreen didChangeDependencies - Liste boş, veriler çekiliyor.');
       _animalStore.fetchAnimals();
    } else {
       print('DEBUG: AnimalListScreen didChangeDependencies - Liste dolu (${_animalStore.animals.length} kayıt).');
    }
  }

  @override
  void initState() {
    super.initState();
     // Arama metin alanındaki değişiklikleri dinle
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Kontrolcüyü ve listener'ı temizle
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // Store burada dispose edilmez, Provider tarafından yönetilir
    super.dispose();
  }

  // Arama metni değiştiğinde çağrılacak metod
  void _onSearchChanged() {
     // TODO: Çok sık API çağrısı yapmamak için burada bir 'debounce' mekanizması eklenebilir (örn. 300-500ms bekle).
     print('DEBUG: Arama metni değişti: ${_searchController.text}');
     _animalStore.fetchAnimals(query: _searchController.text);
  }

  // Yeni Hayvan Ekleme Metodu
  void _addNewAnimal() async {
     print('DEBUG: Yeni Hayvan Ekle butonu tıklandı.');
     // AddEditAnimalScreen'a yönlendir (animalToEdit null olacak)
     // push kullanıyoruz, form ekranından geri dönünce sonucu alacağız
     final result = await Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => const AddEditAnimalScreen(), // animalToEdit null, ekleme modu
       ),
     );

     // AddEditAnimalScreen'dan true dönerse (kaydetme başarılıysa), listeyi yenile
     if (result == true) {
        print('DEBUG: AddEditAnimalScreen\'dan başarılı sonuç döndü, liste yenileniyor.');
        _animalStore.fetchAnimals(query: _animalStore.searchQuery); // Mevcut arama sorgusu ile yenile
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hayvan Listesi'),
        centerTitle: true,
        // HomeScreen'den push ile gelindiği için geri dönüş oku otomatik görünür
        actions: [
          // Yeni Hayvan Ekle butonu
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Hayvan Ekle',
            onPressed: _addNewAnimal, // Metodu çağır
          ),
        ],
      ),
      body: Column( // Arama çubuğu ve listeyi dikeyde sırala
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Hayvan Ara',
                hintText: 'İsme, sahibe veya diğer alanlara göre arama yapın...', // Arama kapsamını belirt
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
               // Arama metni değiştikçe _onSearchChanged metodu tetikleniyor.
            ),
          ),

          // ✨ Yükleniyor, Hata veya Liste Gösterimi ✨
          Expanded( // Kalan alanı liste için kullan
            child: Observer( // MobX durum değişikliklerini dinle (_animalStore)
              builder: (_) {
                // Yükleniyor durumunda ise yüklenme göstergesi göster
                // Sadece liste boşken (veya ilk yükleniyorken) göster, yeni veri çekerken mevcut listeyi göstermeye devam et
                if (_animalStore.isLoading && _animalStore.animals.isEmpty) {
                  print('DEBUG: Observer - Yükleniyor (liste boş).');
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumında hata mesajı göster
                else if (_animalStore.errorMessage != null) {
                  print('DEBUG: Observer - Hata: ${_animalStore.errorMessage}');
                  return Center(
                    child: Text(
                      'Hata: ${_animalStore.errorMessage!}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // Liste boşsa mesaj göster
                else if (_animalStore.animals.isEmpty) {
                   print('DEBUG: Observer - Liste boş.');
                   // Yüklenmiyor değilse ve hata yoksa ve liste boşsa
                  return const Center(child: Text('Kayıtlı hayvan bulunamadı.'));
                }
                // Liste doluysa hayvanları göster
                else {
                   print('DEBUG: Observer - Liste dolu (${_animalStore.animals.length} kayıt), liste gösteriliyor.');
                  return ListView.builder(
                    itemCount: _animalStore.animals.length,
                    itemBuilder: (context, index) {
                      final animal = _animalStore.animals[index];
                      return ListTile(
                        leading: CircleAvatar( // Hayvan türüne göre ikon veya resim olabilir
                          child: Icon(animal.family == 'Kedi' ? Icons.pets : Icons.pets_outlined), 
                        ),
                        title: Text(animal.name ?? 'İsimsiz Hayvan'), // Hayvan Adı (null ise varsayılan metin)
                        subtitle: Text(
                           '${animal.family ?? ''} - ${animal.breed ?? ''}' // Tür - Cins (null ise boş)
                           '${animal.owner != null && animal.owner!.isNotEmpty ? ' - Sahip: ${animal.owner!}' : ''}' // Sahip Adı varsa ve boş değilse ekle
                        ),
                        onTap: () {
                           if (animal.id != null && animal.id!.isNotEmpty) {
                               print('DEBUG: ${animal.name ?? 'Hayvan'} tıklandı. ID: ${animal.id}. Güncelleme ekranına yönlendiriliyor.');
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => AddEditAnimalScreen(animalToEdit: animal), 
                                 ),
                               ).then((result) {
                                  if (result == true) {
                                      print('DEBUG: AddEditAnimalScreen\'dan başarılı sonuç döndü, liste yenileniyor.');
                                      _animalStore.fetchAnimals(query: _animalStore.searchQuery); // Mevcut arama sorgusu ile yenile
                                  }
                               });
                             } else {
                               print('DEBUG: Hayvan ID\'si null veya boş, güncelleme ekranı açılamıyor.');
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Bu hayvan düzenlenemiyor (ID eksik).'),
                                   duration: Duration(seconds: 2),
                                 ),
                               );
                             }
                          },
                      );
                    },
                  );
                }
              },
            ),
          ),
           // Sayfalama (Pagination) kontrolcüler veya bilgi buraya eklenecek
           Observer(
             builder: (_) {
                // Eğer liste doluysa ve toplam kayıt sayısı bilgisi varsa göster
                // totalRowCount bilgisi şu an store'da güncellenmiyor (servis metodunu List<Animal> döndürecek şekilde değiştirdik)
                // Eğer bu bilgiyi göstermek istiyorsanız, servis metodunun PagingResultPayload<Animal> döndürmesi gerekir.
                if (_animalStore.animals.isNotEmpty && _animalStore.totalRowCount > 0) { // totalRowCount hep 0 olacak mevcut durumda
                  return Padding(
                     padding: const EdgeInsets.all(8.0),
                     // Şimdilik sadece yüklenen hayvan sayısını gösterebiliriz
                     child: Text('Toplam ${_animalStore.animals.length} hayvan yüklendi.'),
                     // Eğer totalRowCount doğru geliyorsa alttakini kullanın
                     // child: Text('Toplam ${_animalStore.totalRowCount} kayıt bulundu.'),
                  );
                }
                return const SizedBox.shrink(); // Gösterme
             }
           ),
           // TODO: İleri/Geri Sayfa butonları ve Sayfa Numarası gösterimi eklenecek (totalRowCount, currentPage, pageSize kullanılacak)
        ],
      ),
    );
  }
}