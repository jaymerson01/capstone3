#!/usr/bin/env bash
# Builds the resident app (site root), the admin portal (/admin/) and the
# responder portal (/responder/) into build/web, ready for Firebase Hosting
# or Vercel. Used by deploy_firebase.sh and deploy_vercel.sh.
set -euo pipefail

cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER:-$(command -v flutter || echo "$HOME/development/flutter/bin/flutter")}"
if [ ! -x "$FLUTTER" ]; then
  echo "Flutter not found. Set FLUTTER=/path/to/flutter and try again." >&2
  exit 1
fi

# The app lists .env as an asset, so the build needs the file to exist. The
# deploy scripts never upload it (hidden files are skipped).
[ -f .env ] || touch .env

echo "==> Building the admin portal for /admin/"
rm -rf build/admin_site
"$FLUTTER" build web --release -t lib/main_admin.dart --base-href /admin/
mv build/web build/admin_site

echo "==> Building the responder portal for /responder/"
rm -rf build/responder_site
"$FLUTTER" build web --release -t lib/main_responder.dart --base-href /responder/
mv build/web build/responder_site

echo "==> Building the resident app for /"
"$FLUTTER" build web --release -t lib/main_resident.dart --base-href /
mv build/admin_site build/web/admin
mv build/responder_site build/web/responder

echo "==> Built into build/web (admin portal in build/web/admin, responder portal in build/web/responder)."
