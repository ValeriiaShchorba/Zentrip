class Place {
  final int? id;
  final String title;
  final String description;
  final String city;
  final String country;
  final String imageUrl;
  final String category;
  final int isFavorite;
  final int isVisited;

  Place({
    this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.category,
    this.isFavorite = 0,
    this.isVisited = 0,
  });

  factory Place.fromMap(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      country: json['country'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      isFavorite: json['isFavorite'],
      isVisited: json['isVisited'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'city': city,
      'country': country,
      'imageUrl': imageUrl,
      'category': category,
      'isFavorite': isFavorite,
      'isVisited': isVisited,
    };
  }

  Place copyWith({
    int? id,
    String? title,
    String? description,
    String? city,
    String? country,
    String? imageUrl,
    String? category,
    int? isFavorite,
    int? isVisited,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      country: country ?? this.country,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isVisited: isVisited ?? this.isVisited,
    );
  }
}
