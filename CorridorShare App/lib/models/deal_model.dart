class DealModel {
  final String id;
  final String tripId;
  final String packageId;
  final String travelerId;
  final String senderId;
  double agreedPrice;
  bool dealLocked;
  bool openBoxVerified;
  String status;
  final String packageItem;
  final String routeInfo;
  final String otpSecret;
  final List<ChatMessageModel> chatMessages;

  DealModel({
    required this.id,
    required this.tripId,
    required this.packageId,
    required this.travelerId,
    required this.senderId,
    required this.agreedPrice,
    this.dealLocked = false,
    this.openBoxVerified = false,
    this.status = 'Negotiating',
    this.packageItem = 'Documents & Electronics',
    this.routeInfo = 'Dhaka to Mymensingh N3 Road',
    this.otpSecret = '8821',
    List<ChatMessageModel>? chatMessages,
  }) : chatMessages = chatMessages ?? [];

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id'] ?? '',
      tripId: json['trip_id'] ?? '',
      packageId: json['package_id'] ?? '',
      travelerId: json['traveler_id'] ?? 't-101',
      senderId: json['sender_id'] ?? 's-201',
      agreedPrice: (json['final_agreed_price'] as num?)?.toDouble() ?? 250.0,
      dealLocked: json['deal_locked'] ?? false,
      openBoxVerified: json['open_box_verified'] ?? false,
      status: json['status'] ?? 'Negotiating',
      packageItem: json['package_item'] ?? 'Documents & Electronics',
      routeInfo: json['route_info'] ?? 'Dhaka to Mymensingh N3 Road',
      otpSecret: json['otp_secret'] ?? '8821',
    );
  }
}

class ChatMessageModel {
  final String id;
  final String dealId;
  final String senderId;
  final String senderName;
  final String text;
  final bool isMe;
  final String timestamp;
  final String? imageUrl;

  ChatMessageModel({
    required this.id,
    required this.dealId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.imageUrl,
  });
}
