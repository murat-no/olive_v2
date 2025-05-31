// lib/models/animal.dart

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

  @JsonKey(name: 'family_id') // family_key yerine family_id
  final String? familyId; // Backend'den gelen ID
  @JsonKey(includeToJson: false) // family display
  final String? family;

  @JsonKey(name: 'race_id') // race_key yerine race_id
  final String? raceId; // Backend'den gelen ID
  @JsonKey(includeToJson: false) // race display
  final String? race;

  final String? color; // color_disp yerine color
  @JsonKey(name: 'color_disp') // color_disp hala varsa
  final String? colorDisp;

  @JsonKey(name: 'blood_group')
  final String? bloodGroup;

  @JsonKey(name: 'sex_id') // sex_key yerine sex_id
  final String? sexId; // Backend'den gelen ID
  @JsonKey(includeToJson: false) // sex display
  final String? sex;

  @JsonKey(name: 'birth_date')
  final String? birthDate;

  @JsonKey(name: 'breed_id') // breed_key yerine breed_id
  final String? breedId; // Backend'den gelen ID
  @JsonKey(includeToJson: false) // breed display
  final String? breed;

  final String? markings;
  final String? exceptions;

  @JsonKey(name: 'tracking_method') // tracking_method ID
  final String? trackingMethod;
  @JsonKey(includeToJson: false)
  @JsonKey(name: 'tracking_method_disp') // tracking_method display
  final String? trackingMethodDisp;

  @JsonKey(name: 'tracking_id')
  final String? trackingID;
  @JsonKey(name: 'tracer_location')
  final String? tracerLocation;

  @JsonKey(includeToJson: false) // owner display
  final String? owner;
  @JsonKey(name: 'owner_id') // owner key (UUID)
  final String? ownerId;

  // Sistem alanları
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
    this.family, this.familyId, this.race, this.raceId, this.color, this.colorDisp,
    this.bloodGroup,
    this.sex, this.sexId, this.birthDate, this.breed, this.breedId, this.markings, this.exceptions,
    this.trackingMethod, this.trackingMethodDisp, this.trackingID, this.tracerLocation,
    this.owner, this.ownerId,
    this.createdAt, this.createdBy, this.updatedAt, this.updatedBy,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalToJson(this);
}