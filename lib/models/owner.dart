// lib/models/owner.dart
import 'package:json_annotation/json_annotation.dart';

part 'owner.g.dart'; // json_serializable tarafından üretilecek dosya

@JsonSerializable()
class Owner {
  final String? id; // Backend'den gelen UUID
  @JsonKey(name: 'national_id')
  final String? nationalId; // TC Kimlik No veya benzeri
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? address;
  final String? country;
  final String? city;
  @JsonKey(name: 'city_disp', includeToJson: false) // Sadece backend'den okunacak
  final String? cityDisp;
  final String? district;
  @JsonKey(name: 'district_dsp', includeToJson: false) // Sadece backend'den okunacak
  final String? districtDisp; // district_dsp olarak düzeltildi (SQL'deki district_dsp'ye göre)
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  @JsonKey(name: 'e_mail')
  final String? email;
  final String? phone;
  @JsonKey(name: 'mobile_phone')
  final String? mobilePhone;
  @JsonKey(name: 'contact_id')
  final String? contactId; // Referans owner'ın ID'si
  @JsonKey(name: 'contact_name', includeToJson: false) // Sadece backend'den okunacak
  final String? contactName; // Referans owner'ın tam adı

  // İlişkili hayvanlar listesi
  // Bu alana veri sadece okunurken gelecek, gönderirken null olabilir veya boş gönderilebilir.
  // includeToJson: false ekleyerek toJson'a dahil etmiyoruz.
  final List<OwnerAnimalSummary>? animals; // Backend'den gelen animals listesi

  // Sistem alanları (sadece okunacak)
  @JsonKey(name: 'created_at', includeToJson: false)
  final DateTime? createdAt;
  @JsonKey(name: 'created_by', includeToJson: false)
  final int? createdBy;
  @JsonKey(name: 'updated_at', includeToJson: false)
  final DateTime? updatedAt;
  @JsonKey(name: 'updated_by', includeToJson: false)
  final int? updatedBy;

  Owner({
    this.id,
    this.nationalId,
    this.firstName,
    this.lastName,
    this.address,
    this.country,
    this.city,
    this.cityDisp,
    this.district,
    this.districtDisp,
    this.zipCode,
    this.email,
    this.phone,
    this.mobilePhone,
    this.contactId,
    this.contactName,
    this.animals, // Constructor'da bulunmalı
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  // FullName Computed property (UI için kullanışlı)
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();


  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

// Owner içindeki 'animals' listesindeki her bir hayvanın özet bilgisi
@JsonSerializable()
class OwnerAnimalSummary {
  @JsonKey(name: 'animal_id')
  final String? animalId;
  final String? name;
  @JsonKey(name: 'birth_date')
  final String? birthDate; // SQL'de date() fonksiyonu string döndürüyor olabilir
  @JsonKey(name: 'passport_number')
  final String? passportNumber;

  OwnerAnimalSummary({
    this.animalId,
    this.name,
    this.birthDate,
    this.passportNumber,
  });

  factory OwnerAnimalSummary.fromJson(Map<String, dynamic> json) => _$OwnerAnimalSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerAnimalSummaryToJson(this);
}