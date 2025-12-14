class Donation {
  final int donationID;
  final DateTime donationDate;
  final double bloodVolume;
  final String? location;

  Donation({
    required this.donationID,
    required this.donationDate,
    required this.bloodVolume,
    this.location,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      donationID: json['donationID'] as int,
      donationDate: DateTime.parse(json['donationDate'] as String),
      bloodVolume: (json['bloodVolume'] as num).toDouble(),
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donationID': donationID,
      'donationDate': donationDate.toIso8601String(),
      'bloodVolume': bloodVolume,
      'location': location,
    };
  }

  String get formattedDate {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[donationDate.month - 1]} ${donationDate.day}, ${donationDate.year}';
  }
}

