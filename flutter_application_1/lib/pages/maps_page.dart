import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/message_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  List<MapUser> _nearbyUsers = [];
  double _searchRadius = 40.0; // Raio padrão de 40km
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Coordenadas da Escola Superior de Tecnologia de Setúbal
  static const double _defaultLatitude = 38.521778;  // 38°31'18.4"N
  static const double _defaultLongitude = -8.839278; // 8°50'21.4"W

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Verificar permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Se permissão negada, usar localização padrão
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Se permissão negada permanentemente, usar localização padrão
        _useDefaultLocation();
        return;
      }

      // Tentar obter localização atual
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10), // Timeout de 10 segundos
        );

        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      } catch (e) {
        // Se não conseguir obter localização, usar localização padrão
        print('Erro ao obter localização atual: $e');
        _useDefaultLocation();
        return;
      }

      // procurar Agricultores próximos
      await _fetchNearbyUsers();
      
      // Atualizar localização do Agricultor no Firebase
      await _updateUserLocation();

    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao inicializar mapa: $e';
        _isLoading = false;
      });
    }
  }

  void _useDefaultLocation() {
    setState(() {
      _currentPosition = Position(
        latitude: _defaultLatitude,
        longitude: _defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      _isLoading = false;
    });
    
    // procurar Agricultores próximos da localização padrão
    _fetchNearbyUsers();
  }

  Future<void> _updateUserLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _currentPosition != null) {
        final database = FirebaseDatabase.instance.ref();
        
        // Tentar obter o endereço a partir das coordenadas atuais
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final address = [
              placemark.street,
              placemark.subLocality,
              placemark.locality,
              placemark.administrativeArea,
              placemark.postalCode,
              placemark.country,
            ].where((part) => part != null && part.isNotEmpty).join(', ');
            
            await database.child('userdata/${user.uid}/address').set(address);
          }
        } catch (e) {
          print('Erro ao obter endereço das coordenadas: $e');
          // Se não conseguir obter o endereço, salvar pelo menos as coordenadas
          await database.child('userdata/${user.uid}/location').set({
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    } catch (e) {
      print('Erro ao atualizar localização: $e');
    }
  }

  Future<void> _fetchNearbyUsers() async {
    try {
      if (_currentPosition == null) return;

      final database = FirebaseDatabase.instance.ref();
      final snapshot = await database.child('userdata').get();

      if (snapshot.value != null) {
        final Map<dynamic, dynamic> usersData = 
            snapshot.value as Map<dynamic, dynamic>;
        
        List<MapUser> nearbyUsers = [];

        for (var entry in usersData.entries) {
          final userData = entry.value as Map<dynamic, dynamic>;
          final address = userData['address']?.toString();
          
          if (address != null && address.isNotEmpty) {
            try {
              // Converter endereço em coordenadas usando geocoding
              List<Location> locations = await locationFromAddress(address);
              
              if (locations.isNotEmpty) {
                final userLat = locations.first.latitude;
                final userLng = locations.first.longitude;
                
                final distance = Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  userLat,
                  userLng,
                );

                if (distance <= _searchRadius * 1000) { // Converter km para metros
                  nearbyUsers.add(MapUser(
                    uid: entry.key,
                    name: userData['name'] ?? 'Agricultor',
                    email: userData['email'] ?? '',
                    address: address,
                    latitude: userLat,
                    longitude: userLng,
                    distance: distance,
                  ));
                }
              }
            } catch (e) {
              print('Erro ao geocodificar endereço "$address": $e');
              // Continuar para o próximo Agricultor se não conseguir geocodificar
              continue;
            }
          }
        }

        // Ordenar por distância
        nearbyUsers.sort((a, b) => a.distance.compareTo(b.distance));

        setState(() {
          _nearbyUsers = nearbyUsers.where((user) => user.uid != FirebaseAuth.instance.currentUser?.uid).toList();
        });
      }
    } catch (e) {
      print('Erro ao procurar Agricultores próximos: $e');
    }
  }

  void _updateRadius(double newRadius) {
    setState(() {
      _searchRadius = newRadius;
    });
    _fetchNearbyUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Agricultores'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Agricultores'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de Agricultores'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Não foi possível obter a localização'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Agricultores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchNearbyUsers();
              _updateUserLocation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Controles de raio
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Raio de procura: '),
                    Text('${_searchRadius.toInt()} km'),
                  ],
                ),
                Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  label: '${_searchRadius.toInt()} km',
                  onChanged: _updateRadius,
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 12.0, // Zoom mais próximo para Setúbal
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_application_1',
                ),
                // Marcador da localização atual/padrão
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                          if (_currentPosition!.latitude == _defaultLatitude && 
                              _currentPosition!.longitude == _defaultLongitude)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ESTSetúbal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Marcadores dos Agricultores próximos
                    ..._nearbyUsers.map((user) => Marker(
                      point: LatLng(user.latitude, user.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showUserInfo(user);
                        },
                        child: Image.asset('assets/images/farm_icon.png', width: 60, height: 60),
                      ),
                    )).toList(),
                  ],
                ),
                // Círculo do raio de procura
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      radius: _searchRadius * 1000, // Converter km para metros
                      color: Colors.blue.withOpacity(0.1),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de Agricultores próximos
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Agricultores próximos (${_nearbyUsers.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _nearbyUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum Agricultor encontrado neste raio',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _nearbyUsers.length,
                            itemBuilder: (context, index) {
                              final user = _nearbyUsers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    user.name.isNotEmpty 
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name.isNotEmpty ? user.name : 'Agricultor',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.address,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${(user.distance / 1000).toStringAsFixed(1)} km de distância',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.message),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MessagePage(otherUserID: user.uid, userName: user.name)));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.location_on),
                                      onPressed: () {
                                        _mapController.move(
                                          LatLng(user.latitude, user.longitude),
                                          15.0,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () => _showUserInfo(user),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserInfo(MapUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name.isNotEmpty ? user.name : 'Agricultor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('Endereço: ${user.address}'),
            const SizedBox(height: 8),
            Text('Distância: ${(user.distance / 1000).toStringAsFixed(1)} km'),
            const SizedBox(height: 8),
            Text('Coordenadas: ${user.latitude.toStringAsFixed(6)}, ${user.longitude.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                '/message',
                arguments: {
                  'uid': user.uid,
                  'name': user.name.isNotEmpty ? user.name : 'Agricultor',
                },
              );
            },
            icon: const Icon(Icons.message),
            label: const Text('Conversar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _mapController.move(
                LatLng(user.latitude, user.longitude),
                15.0,
              );
            },
            child: const Text('Ver no Mapa'),
          ),
        ],
      ),
    );
  }
}

class MapUser {
  final String uid;
  final String name;
  final String email;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;

  MapUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
} 