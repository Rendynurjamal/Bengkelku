class ServiceData {
  final String name;
  final String price;
  final String duration;

  const ServiceData({
    required this.name,
    required this.price,
    required this.duration,
  });
}

class VehicleData {
  final String name;
  final String icon;
  final List<ServiceData> services;

  const VehicleData({
    required this.name,
    required this.icon,
    required this.services,
  });
}

const List<VehicleData> vehicleList = [
  VehicleData(
    name: 'Motor',
    icon: '🏍️',
    services: [
      ServiceData(name: 'Ganti Oli', price: 'Rp50.000', duration: '30 - 45 menit'),
      ServiceData(name: 'Servis Mesin', price: 'Rp100.000', duration: '1 - 2 jam'),
      ServiceData(name: 'Servis Rem', price: 'Rp75.000', duration: '45 - 60 menit'),
      ServiceData(name: 'Kelistrikan', price: 'Rp80.000', duration: '45 - 90 menit'),
      ServiceData(name: 'Servis AC', price: 'Rp150.000', duration: '1 - 2 jam'),
      ServiceData(name: 'Servis Transmisi', price: 'Rp300.000', duration: '2 - 4 jam'),
    ],
  ),
  VehicleData(
    name: 'Mobil',
    icon: '🚗',
    services: [
      ServiceData(name: 'Ganti Oli', price: 'Rp100.000', duration: '30 - 60 menit'),
      ServiceData(name: 'Servis Mesin', price: 'Rp200.000', duration: '1 - 3 jam'),
      ServiceData(name: 'Servis Rem', price: 'Rp150.000', duration: '1 - 2 jam'),
      ServiceData(name: 'Kelistrikan', price: 'Rp120.000', duration: '1 - 2 jam'),
      ServiceData(name: 'Servis AC', price: 'Rp250.000', duration: '1 - 2 jam'),
      ServiceData(name: 'Servis Transmisi', price: 'Rp450.000', duration: '2 - 5 jam'),
    ],
  ),
];
