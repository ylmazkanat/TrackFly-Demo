// models/flight.dart
class Flight {
  final String flightNumber;
  final String departure;
  final String arrival;

  Flight({required this.flightNumber, required this.departure, required this.arrival});

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNumber: json['flight_number'],
      departure: json['departure'],
      arrival: json['arrival'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight_number': flightNumber,
      'departure': departure,
      'arrival': arrival,
    };
  }
}
