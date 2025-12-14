class Appointment {
  final int transfusionID;
  final DateTime appointmentDate;
  final String? appointmentTime;
  final String? location;
  final String status; // 'Pending', 'Completed'
  final int quantityRequested;
  final String patientName;
  final DateTime transfusionRequestDate;

  Appointment({
    required this.transfusionID,
    required this.appointmentDate,
    this.appointmentTime,
    this.location,
    required this.status,
    required this.quantityRequested,
    required this.patientName,
    required this.transfusionRequestDate,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      transfusionID: json['transfusionID'] as int,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String?,
      location: json['location'] as String?,
      status: json['statusText'] as String? ?? json['status'] as String? ?? 'Pending',
      quantityRequested: json['quantityRequested'] as int? ?? 0,
      patientName: json['patientName'] as String? ?? '',
      transfusionRequestDate: json['transfusionRequestDate'] != null
          ? DateTime.parse(json['transfusionRequestDate'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transfusionID': transfusionID,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'location': location,
      'status': status,
      'quantityRequested': quantityRequested,
      'patientName': patientName,
      'transfusionRequestDate': transfusionRequestDate.toIso8601String(),
    };
  }

  bool get isUpcoming => status == 'Pending' && appointmentDate.isAfter(DateTime.now());
  bool get isPast => status == 'Completed' || appointmentDate.isBefore(DateTime.now());
  
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 
                      'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[appointmentDate.weekday - 1]}, ${appointmentDate.day} ${months[appointmentDate.month - 1]}';
  }
}

