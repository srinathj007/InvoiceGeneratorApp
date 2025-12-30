class BusinessProfile {
  final String? id;
  final String userId;
  final String businessName;
  final String address;
  final String proprietor;
  final String phoneNumbers;
  final String? logoUrl;

  BusinessProfile({
    this.id,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.proprietor,
    required this.phoneNumbers,
    this.logoUrl,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'],
      userId: json['user_id'],
      businessName: json['business_name'] ?? '',
      address: json['address'] ?? '',
      proprietor: json['proprietor'] ?? '',
      phoneNumbers: json['phone_numbers'] ?? '',
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'business_name': businessName,
      'address': address,
      'proprietor': proprietor,
      'phone_numbers': phoneNumbers,
      'logo_url': logoUrl,
    };
  }

  BusinessProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? address,
    String? proprietor,
    String? phoneNumbers,
    String? logoUrl,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      proprietor: proprietor ?? this.proprietor,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
