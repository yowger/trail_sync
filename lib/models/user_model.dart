class AppUser {
  final String id;
  final String name;
  final String? imageUrl;

  const AppUser({required this.id, required this.name, this.imageUrl});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl};
  }
}
