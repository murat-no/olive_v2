// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
      id: json['id'] as String?,
      nationalId: json['national_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      cityDisp: json['city_disp'] as String?,
      district: json['district'] as String?,
      districtDisp: json['district_dsp'] as String?,
      zipCode: json['zip_code'] as String?,
      email: json['e_mail'] as String?,
      phone: json['phone'] as String?,
      mobilePhone: json['mobile_phone'] as String?,
      contactId: json['contact_id'] as String?,
      contactName: json['contact_name'] as String?,
      animals: (json['animals'] as List<dynamic>?)
          ?.map((e) => OwnerAnimalSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      createdBy: (json['created_by'] as num?)?.toInt(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      updatedBy: (json['updated_by'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'id': instance.id,
      'national_id': instance.nationalId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'address': instance.address,
      'country': instance.country,
      'city': instance.city,
      'district': instance.district,
      'zip_code': instance.zipCode,
      'e_mail': instance.email,
      'phone': instance.phone,
      'mobile_phone': instance.mobilePhone,
      'contact_id': instance.contactId,
      'animals': instance.animals,
    };

OwnerAnimalSummary _$OwnerAnimalSummaryFromJson(Map<String, dynamic> json) =>
    OwnerAnimalSummary(
      animalId: json['animal_id'] as String?,
      name: json['name'] as String?,
      birthDate: json['birth_date'] as String?,
      passportNumber: json['passport_number'] as String?,
    );

Map<String, dynamic> _$OwnerAnimalSummaryToJson(OwnerAnimalSummary instance) =>
    <String, dynamic>{
      'animal_id': instance.animalId,
      'name': instance.name,
      'birth_date': instance.birthDate,
      'passport_number': instance.passportNumber,
    };
