// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opensky_flutter_app/models/opensky.dart';
import 'package:http/http.dart' as http;
import 'package:opensky_flutter_app/screens/login_screen.dart';

// Halaman Dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Aircraft> aircraft = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAircraft();
  }

  Future<void> fetchAircraft() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final uri = Uri.https('opensky-network.org', 'api/states/all', {
        'lamin': '0.5',
        'lomin': '103.5',
        'lamax': '1.8',
        'lomax': '105.2',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}. '
          'Coba lagi beberapa saat kemudian.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final states = data['states'] as List<dynamic>? ?? [];
      final result = states
          .map((state) => Aircraft(state as List<dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        aircraft = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error =
            'Gagal mengambil data OpenSky.\n'
            'Periksa koneksi internet atau coba lagi.\n\n$e';
        loading = false;
      });
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String formatAltitude(double? value) {
    if (value == null) return 'Tidak tersedia';
    return '${value.toStringAsFixed(0)} m';
  }

  String formatSpeed(double? value) {
    if (value == null) return 'Tidak tersedia';
    return '${(value * 3.6).toStringAsFixed(1)} km/jam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenSky Tracker'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: loading ? null : fetchAircraft,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Penerbangan',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('Area pemantauan: Batam'),
                Text('Sumber data: OpenSky Network API'),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 55),
                          const SizedBox(height: 12),
                          Text(error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: fetchAircraft,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchAircraft,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.airplanemode_active,
                              size: 36,
                              color: Colors.blue,
                            ),
                            title: const Text('Pesawat terdeteksi'),
                            subtitle: const Text('Berdasarkan response API'),
                            trailing: Text(
                              '${aircraft.length}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (aircraft.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Tidak ada pesawat yang terdeteksi '
                              'di area ini saat ini.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ...aircraft.map((plane) {
                          return Card(
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.flight),
                              ),
                              title: Text(plane.callsign),
                              subtitle: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(text: 'Negara asal: '),
                                    TextSpan(
                                      text: plane.country,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              childrenPadding: const EdgeInsets.all(16),
                              children: [
                                _detail('ICAO24', plane.icao),
                                _detail(
                                  'Status',
                                  plane.onGround ? 'Di darat' : 'Di udara',
                                ),
                                _detail(
                                  'Ketinggian',
                                  formatAltitude(plane.altitude),
                                ),
                                _detail(
                                  'Kecepatan',
                                  formatSpeed(plane.velocity),
                                ),
                                _detail(
                                  'Latitude',
                                  plane.latitude?.toStringAsFixed(5) ??
                                      'Tidak tersedia',
                                ),
                                _detail(
                                  'Longitude',
                                  plane.longitude?.toStringAsFixed(5) ??
                                      'Tidak tersedia',
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
