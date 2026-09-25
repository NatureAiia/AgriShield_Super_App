/// The one shared farmer/field record — docs/roadmap/README.md's
/// "Foundation" — read by every V1 part rather than each owning its own copy.
class Farmer {
  final String phone;
  final String name;
  final String location;
  final String crop;
  final String storageHub;

  const Farmer({
    required this.phone,
    required this.name,
    required this.location,
    required this.crop,
    required this.storageHub,
  });

  /// Safety-net fallback only — see FarmerRepository.load(). Real farmer
  /// records now come from AuthService's sign-up/sign-in flow; this
  /// should only ever be reached if a signed-in session's local farmer
  /// cache went missing without the session itself being cleared too.
  factory Farmer.demo() => const Farmer(
        phone: '',
        name: 'Tendai Moyo',
        location: 'Harare South',
        crop: 'Maize',
        storageHub: 'Mbare Collection Point',
      );

  Farmer copyWith({String? phone, String? name, String? location, String? crop, String? storageHub}) {
    return Farmer(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      location: location ?? this.location,
      crop: crop ?? this.crop,
      storageHub: storageHub ?? this.storageHub,
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'location': location,
        'crop': crop,
        'storage_hub': storageHub,
      };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
        phone: json['phone'] as String? ?? '',
        name: json['name'] as String,
        location: json['location'] as String,
        crop: json['crop'] as String,
        storageHub: json['storage_hub'] as String,
      );
}
