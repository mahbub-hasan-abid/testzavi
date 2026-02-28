class UserAddress {
  final String geohash;
  final double lat;
  final double lng;

  const UserAddress({
    required this.geohash,
    required this.lat,
    required this.lng,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      geohash: json['geohash'] as String? ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lng: double.tryParse(json['long']?.toString() ?? '0') ?? 0,
    );
  }
}

class UserName {
  final String firstname;
  final String lastname;

  const UserName({required this.firstname, required this.lastname});

  factory UserName.fromJson(Map<String, dynamic> json) {
    return UserName(
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
    );
  }

  String get fullName => '$firstname $lastname';
}

class UserModel {
  final int id;
  final String email;
  final String username;
  final String phone;
  final UserName name;
  final UserAddress address;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.name,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: UserName.fromJson(json['name'] as Map<String, dynamic>? ?? {}),
      address: UserAddress.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
