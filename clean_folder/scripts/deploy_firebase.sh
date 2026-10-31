#!/usr/bin/env bash
# Builds the resident app (site root) and the admin portal (/admin/) and
# deploys both to Firebase Hosting. Deploys hosting only: Firestore rules,
# Storage rules and Cloud Functions are never touched.
#
#   ./scripts/deploy_firebase.sh               build, then deploy
#   ./scripts/deploy_firebase.sh --build-only  build only (to check build/web)
#
# Afterwards:
#   https://resq-community-safety.web.app          resident app
#   https://resq-community-safety.web.app/admin/   admin portal
#
# Note: firebase.json skips hidden files when uploading, so .env (and any key
# in it) never reaches the public site; features that need it stay off there.
set -euo pipefail

cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER:-$(command -v flutter || echo "$HOME/development/flutter/bin/flutter")}"
PROJECT="${FIREBASE_PROJECT:-resq-community-safety}"
# The Firebase CLI installed with npm into ~/development/node.
[ -d "$HOME/development/node/bin" ] && PATH="$PATH:$HOME/development/node/bin"
BUILD_ONLY=false
[ "${1:-}" = "--build-only" ] && BUILD_ONLY=true

if [ ! -x "$FLUTTER" ]; then
  echo "Flutter not found. Set FLUTTER=/path/to/flutter and try again." >&2
  exit 1
fi
if ! $BUILD_ONLY && ! command -v firebase >/dev/null; then
  echo "The Firebase CLI isn't installed. Install it with:" >&2
  echo "  curl -sL https://firebase.tools | bash" >&2
  echo "then sign in with: firebase login" >&2
  exit 1
fi

# The app lists .env as an asset, so the build needs the file to exist.
[ -f .env ] || touch .env

echo "==> Building the admin portal for /admin/"
rm -rf build/admin_site
"$FLUTTER" build web --release -t lib/main_admin.dart --base-href /admin/
mv build/web build/admin_site

echo "==> Building the resident app for /"
"$FLUTTER" build web --release -t lib/main_resident.dart --base-href /
mv build/admin_site build/web/admin

if $BUILD_ONLY; then
  echo "==> Built into build/web (admin portal in build/web/admin). Not deployed."
  exit 0
fi

echo "==> Deploying to Firebase Hosting ($PROJECT)"
firebase deploy --only hosting --project "$PROJECT"

echo
echo "Live:"
echo "  Resident app:  https://$PROJECT.web.app"
echo "  Admin portal:  https://$PROJECT.web.app/admin/"
