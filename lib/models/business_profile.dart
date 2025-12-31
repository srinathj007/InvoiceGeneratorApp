class BusinessProfile {
  final String? id;
  final String userId;
  final String businessName;
  final String address;
  final String proprietor;
  final String phoneNumbers;
  final String? logoUrl;
  final String? signatureUrl;
  final String? customLogo1Url;
  final String? customLogo2Url;
  final String? customLogo3Url;
  final String? customLogo4Url;
  final String? customFieldLabel;      // Generic label for an extra field
  final String? customFieldPlaceholder; // Generic placeholder for an extra field

  BusinessProfile({
    this.id,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.proprietor,
    required this.phoneNumbers,
    this.logoUrl,
    this.signatureUrl,
    this.customLogo1Url,
    this.customLogo2Url,
    this.customLogo3Url,
    this.customLogo4Url,
    this.customFieldLabel,
    this.customFieldPlaceholder,
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
      signatureUrl: json['signature_url'],
      customLogo1Url: json['custom_logo_1_url'],
      customLogo2Url: json['custom_logo_2_url'],
      customLogo3Url: json['custom_logo_3_url'],
      customLogo4Url: json['custom_logo_4_url'],
      customFieldLabel: json['custom_field_label'],
      customFieldPlaceholder: json['custom_field_placeholder'],
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
      'signature_url': signatureUrl,
      'custom_logo_1_url': customLogo1Url,
      'custom_logo_2_url': customLogo2Url,
      'custom_logo_3_url': customLogo3Url,
      'custom_logo_4_url': customLogo4Url,
      'custom_field_label': customFieldLabel,
      'custom_field_placeholder': customFieldPlaceholder,
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
    String? signatureUrl,
    String? customLogo1Url,
    String? customLogo2Url,
    String? customLogo3Url,
    String? customLogo4Url,
    String? customFieldLabel,
    String? customFieldPlaceholder,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      proprietor: proprietor ?? this.proprietor,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      customLogo1Url: customLogo1Url ?? this.customLogo1Url,
      customLogo2Url: customLogo2Url ?? this.customLogo2Url,
      customLogo3Url: customLogo3Url ?? this.customLogo3Url,
      customLogo4Url: customLogo4Url ?? this.customLogo4Url,
      customFieldLabel: customFieldLabel ?? this.customFieldLabel,
      customFieldPlaceholder: customFieldPlaceholder ?? this.customFieldPlaceholder,
    );
  }
}
