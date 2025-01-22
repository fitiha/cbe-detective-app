class VerificationResponse {
  final bool isValid;
  final String payer;
  final String amount;
  final String date;

  VerificationResponse({
    required this.isValid,
    required this.payer,
    required this.amount,
    required this.date,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      isValid: json['isValid'] ?? false,
      payer: json['payer'] ?? '',
      amount: json['amount'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
