// Model Data Pesawat
class Aircraft {
  final String icao;
  final String callsign;
  final String country;
  final double? longitude;
  final double? latitude;
  final double? altitude;
  final double? velocity;
  final bool onGround;

  Aircraft(List<dynamic> state)
    : icao = state[0]?.toString() ?? '-',
      callsign =
        state[1]?.toString().trim().isNotEmpty == true
          ? state[1].toString().trim()
          : 'Tidak diketahui',
      country = state[2]?.toString() ?? '-',
      longitude = (state[5] as num?)?.toDouble(),
      latitude = (state[6] as num?)?.toDouble(),
      altitude = (state[7] as num?)?.toDouble(),
      onGround = state[8] == true,
      velocity = (state[9] as num?)?.toDouble();
}