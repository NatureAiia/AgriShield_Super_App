/// The one shared farmer/field record — docs/roadmap/README.md's
/// "Foundation" — read by every V1 part rather than each owning its own copy.
class Farmer {
  final String name;
  final String location;
  final String crop;
  final String storageHub;

  const Farmer({
    required this.name,
    required this.location,
    required this.crop,
    required this.storageHub,
  });

  factory Farmer.demo() => const Farmer(
        name: 'Tendai Moyo',
        location: 'Harare South',
        crop: 'Maize',
        storageHub: 'Mbare Collection Point',
      );

  Farmer copyWith({String? name, String? location, String? crop, String? storageHub}) {
    return Farmer(
      name: name ?? this.name,
      location: location ?? this.location,
      crop: crop ?? this.crop,
      storageHub: storageHub ?? this.storageHub,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'crop': crop,
        'storage_hub': storageHub,
      };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
        name: json['name'] as String,
        location: json['location'] as String,
        crop: json['crop'] as String,
        storageHub: json['storage_hub'] as String,
      );
}
