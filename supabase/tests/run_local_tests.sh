#!/usr/bin/env bash
# ============================================================
# Miyhav · Yerel RLS test koşucusu (PostgreSQL 16).
# Supabase'e ağ erişimi olmayan ortamlarda migration'ları ve RLS davranışlarını
# gerçek Postgres üzerinde doğrular. Ephemeral bir test veritabanı kullanır.
# postgres kullanıcısı ile çalıştırılmalıdır (peer auth). Örnek:
#   su postgres -c "SUPA_DIR=/path/to/supabase bash run_local_tests.sh"
# ============================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPA_DIR="${SUPA_DIR:-$(cd "$HERE/.." && pwd)}"
DB="${DB:-miyhav_local_test}"

dropdb --if-exists "$DB" >/dev/null 2>&1 || true
createdb "$DB"

psql -d "$DB" -v ON_ERROR_STOP=1 \
  -f "$HERE/_shim_local.sql" \
  -f "$SUPA_DIR/migrations/20260714093000_create_profiles.sql" \
  -f "$SUPA_DIR/migrations/20260715120000_privacy_discovery.sql" \
  -f "$HERE/profiles_rls_test.sql" \
  -f "$HERE/privacy_rls_test.sql"

dropdb "$DB"
echo "OK: tüm yerel RLS testleri geçti"
