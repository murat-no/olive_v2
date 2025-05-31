// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Animal _$AnimalFromJson(Map<String, dynamic> json) => Animal(
      id: json['id'] as String?,
      name: json['name'] as String?,
      alternateName: json['alternate_name'] as String?,
      passportNumber: json['passport_number'] as String?,
      family: json['family'] as String?,
      familyId: json['family_id'] as String?,
      race: json['race'] as String?,
      raceId: json['race_id'] as String?,
      color: json['color'] as String?,
      colorDisp: json['color_disp'] as String?,
      bloodGroup: json['blood_group'] as String?,
      sex: json['sex'] as String?,
      sexId: json['sex_id'] as String?,
      birthDate: json['birth_date'] as String?,
      breed: json['breed'] as String?,
      breedId: json['breed_id'] as String?,
      markings: json['markings'] as String?,
      exceptions: json['exceptions'] as String?,
      trackingMethod: json['tracking_method'] as String?,
      trackingMethodDisp: json['trackingMethodDisp'] as String?,
      trackingID: json['tracking_id'] as String?,
      tracerLocation: json['tracer_location'] as String?,
      owner: json['owner'] as String?,
      ownerId: json['owner_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      createdBy: (json['created_by'] as num?)?.toInt(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      updatedBy: (json['updated_by'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AnimalToJson(Animal instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'alternate_name': instance.alternateName,
      'passport_number': instance.passportNumber,
      'family_id': instance.familyId,
      'race_id': instance.raceId,
      'color': instance.color,
      'color_disp': instance.colorDisp,
      'blood_group': instance.bloodGroup,
      'sex_id': instance.sexId,
      'birth_date': instance.birthDate,
      'breed_id': instance.breedId,
      'markings': instance.markings,
      'exceptions': instance.exceptions,
      'tracking_method': instance.trackingMethod,
      'tracking_id': instance.trackingID,
      'tracer_location': instance.tracerLocation,
      'owner_id': instance.ownerId,
    };
