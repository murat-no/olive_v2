import 'package:json_annotation/json_annotation.dart';

part 'animal.g.dart';

@JsonSerializable()
class Animal {
  final String? id;
  final String? name;
  @JsonKey(name: 'alternate_name')
  final String? alternateName;
  @JsonKey(name: 'passport_number')
  final String? passportNumber;

  // ✨ Display alanlarını JSON'dan hariç tutmak için includeToJson: false eklendi ✨
  @JsonKey(includeToJson: false)
  final String? family;
  @JsonKey(name: 'family_key')
  final String? familyKey;
  @JsonKey(includeToJson: false)
  final String? race;
  @JsonKey(name: 'race_key')
  final String? raceKey;
  @JsonKey(includeToJson: false)
  final String? color; // Eğer color için de key varsa burası da güncellenmeli
  @JsonKey(name: 'color_disp')
  final String? colorDisp; // Eğer color_disp için de key varsa burası da güncellenmeli

  @JsonKey(name: 'blood_group') // BloodGroup'un key'i yok, metin alanı gönderiliyor
  final String? bloodGroup;

  @JsonKey(includeToJson: false)
  final String? sex;
  @JsonKey(name: 'sex_key')
  final String? sexKey;

  @JsonKey(name: 'birth_date') // birth_date string olarak kalacak
  final String? birthDate;

  @JsonKey(includeToJson: false)
  final String? breed;
  @JsonKey(name: 'breed_key')
  final String? breedKey;

  final String? markings;
  final String? exceptions;

  @JsonKey(name: 'tracking_method') // tracking_method alanı key değeri tutuyor
  final String? trackingMethod;
  @JsonKey(includeToJson: false)
  @JsonKey(name: 'tracking_method_disp') // Eğer tracking_method_disp için de key varsa burası da güncellenmeli
  final String? trackingMethodDisp;

  @JsonKey(name: 'tracking_id')
  final String? trackingID;
  @JsonKey(name: 'tracer_location')
  final String? tracerLocation;

  @JsonKey(includeToJson: false)
  final String? owner; // Owner display
  @JsonKey(name: 'owner_id')
  final String? ownerId; // Owner key

  // Sistem alanları frontend'den gönderilmeyecek, sadece backend'den okunacak.
  // includeToJson: false ekleyerek backend'e göndermeyi engelliyoruz.
  // fromJson'da parse edilirken sorun olmaz, çünkü bu alanlar backend'den geliyor.
  @JsonKey(name: 'created_at', includeToJson: false) 
  final DateTime? createdAt;
  @JsonKey(name: 'created_by', includeToJson: false) 
  final int? createdBy;
  @JsonKey(name: 'updated_at', includeToJson: false) 
  final DateTime? updatedAt;
  @JsonKey(name: 'updated_by', includeToJson: false) 
  final int? updatedBy;


  Animal({
    this.id, this.name, this.alternateName, this.passportNumber,
    this.family, this.familyKey, this.race, this.raceKey, this.color, this.colorDisp,
    this.bloodGroup,
    this.sex, this.sexKey, this.birthDate, this.breed, this.breedKey, this.markings, this.exceptions,
    this.trackingMethod, this.trackingMethodDisp, this.trackingID, this.tracerLocation,
    this.owner, this.ownerId,
    this.createdAt, this.createdBy, this.updatedAt, this.updatedBy, // Constructor'da kalabilir, fromJson set edecek.
  });

  factory Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalToJson(this); // Bu metod, includeToJson: false olan alanları atlayacak
}