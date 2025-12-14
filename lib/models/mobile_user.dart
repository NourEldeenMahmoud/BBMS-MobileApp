class MobileUser {
  final int mobileUserID;
  final int personID;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String bloodType;
  final DateTime? dateOfBirth;
  final String? address;
  final String? imagePath;

  MobileUser({
    required this.mobileUserID,
    required this.personID,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    required this.bloodType,
    this.dateOfBirth,
    this.address,
    this.imagePath,
  });

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    return MobileUser(
      mobileUserID: json['mobileUserID'] as int,
      personID: json['personID'] as int,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String? ?? json['firstName'] + ' ' + json['lastName'],
      email: json['email'] as String? ?? '',
      bloodType: json['bloodType'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      address: json['address'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobileUserID': mobileUserID,
      'personID': personID,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'email': email,
      'bloodType': bloodType,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'imagePath': imagePath,
    };
  }

  MobileUser copyWith({
    int? mobileUserID,
    int? personID,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? bloodType,
    DateTime? dateOfBirth,
    String? address,
    String? imagePath,
  }) {
    return MobileUser(
      mobileUserID: mobileUserID ?? this.mobileUserID,
      personID: personID ?? this.personID,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

