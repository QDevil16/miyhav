import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/supabase_bootstrap.dart';
import '../data/discovery_repository.dart';

/// Keşif/arama için güvenli veri erişim temeli (sonraki DISCOVERY görevleri için).
final Provider<DiscoveryRepository> discoveryRepositoryProvider =
    Provider<DiscoveryRepository>((ref) {
      return SupabaseDiscoveryRepository(ref.watch(supabaseClientProvider));
    });
