import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/networking/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SupabaseStatus status = await SupabaseBootstrap.initialize();
  runApp(ProviderScope(child: MiyhavApp(supabaseStatus: status)));
}
