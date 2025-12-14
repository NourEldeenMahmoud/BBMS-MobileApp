enum NotificationType {
  appointment,
  eligibility,
  thankYou,
  info,
  communityImpact,
}

class Notification {
  final int notificationID;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdDate;
  final int? transfusionID;
  final int? donationID;

  Notification({
    required this.notificationID,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdDate,
    this.transfusionID,
    this.donationID,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationID: json['notificationID'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseNotificationType(json['notificationType'] as String? ?? 'Info'),
      isRead: json['isRead'] as bool? ?? false,
      createdDate: DateTime.parse(json['createdDate'] as String),
      transfusionID: json['transfusionID'] as int?,
      donationID: json['donationID'] as int?,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return NotificationType.appointment;
      case 'eligibility':
        return NotificationType.eligibility;
      case 'thankyou':
      case 'thank_you':
        return NotificationType.thankYou;
      case 'communityimpact':
      case 'community_impact':
        return NotificationType.communityImpact;
      default:
        return NotificationType.info;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationID': notificationID,
      'title': title,
      'message': message,
      'notificationType': type.toString().split('.').last,
      'isRead': isRead,
      'createdDate': createdDate.toIso8601String(),
      'transfusionID': transfusionID,
      'donationID': donationID,
    };
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

