import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/discovery_profile.dart';

/// Keşif/arama için güvenli veri erişim temeli (DISCOVERY görevleri kullanacak).
///
/// UI YOK. Yalnızca güvenli projeksiyon (`search_profiles` RPC / `public_profiles`
/// view) üzerinden sınırlı profil bilgisi döner. Doğrudan `profiles` tablosuna
/// gitmez.
abstract interface class DiscoveryRepository {
  /// Kullanıcı adına göre (case-insensitive prefix) keşfedilebilir profilleri arar.
  /// private ve aktif olmayan profiller sonuçta bulunmaz (server tarafında).
  Future<List<DiscoveryProfile>> searchByUsername(String query);
}

/// [DiscoveryRepository]'nin Supabase uygulaması. Güvenli `search_profiles` RPC'sini
/// çağırır (SECURITY DEFINER; yalnızca izin verilen 5 kolonu döndürür).
class SupabaseDiscoveryRepository implements DiscoveryRepository {
  SupabaseDiscoveryRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<DiscoveryProfile>> searchByUsername(String query) async {
    final String term = query.trim();
    if (term.isEmpty) return const <DiscoveryProfile>[];
    final List<dynamic> rows = await _client.rpc(
      'search_profiles',
      params: <String, dynamic>{'search': term},
    );
    return rows
        .cast<Map<String, dynamic>>()
        .map(DiscoveryProfile.fromMap)
        .toList(growable: false);
  }
}
