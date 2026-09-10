class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.sellerId,
    this.sellerName,
    required this.title,
    this.description,
    required this.price,
    required this.category,
    this.images = const [],
    this.status = 'active', // 'active', 'sold', 'removed', 'flagged'
    this.createdAt,
  });

  final String id;
  final String sellerId;
  final String? sellerName;
  final String title;
  final String? description;
  final double price;
  final String category; // 'books', 'electronics', 'notes_bundle', 'drafter_tools', 'uniform'
  final List<String> images;
  final String status;
  final DateTime? createdAt;

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final rawImages = json['image_urls'] ?? json['images'];
    return MarketplaceListing(
      id: json['id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      sellerName: json['seller_name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'books',
      images: (rawImages as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'image_urls': images,
      'status': status,
    };
  }

  MarketplaceListing copyWith({
    String? title,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    String? status,
    String? sellerName,
  }) {
    return MarketplaceListing(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName ?? this.sellerName,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
