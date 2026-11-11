#!/usr/bin/env bash
# Builds the resident app (site root), the admin portal (/admin/) and the
# responder portal (/responder/) and deploys them to Firebase Hosting.
# Deploys hosting only: Firestore rules, Storage rules and Cloud Functions are
# never touched.
#
#   ./scripts/deploy_firebase.sh               build, then deploy
#   ./scripts/deploy_firebase.sh --build-only  build only (to check build/web)
#   ./scripts/deploy_firebase.sh --skip-build  deploy the existing build/web
#
# Afterwards:
#   https://resq-community-safety.web.app          resident app
#   https://resq-community-safety.web.app/admin/   admin portal
#
# Note: firebase.json skips hidden files when uploading, so .env (and any key
# in it) never reaches the public site; features that need it stay off there.
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="${FIREBASE_PROJECT:-resq-community-safety}"
# The Firebase CLI installed with npm into ~/development/node.
[ -d "$HOME/development/node/bin" ] && PATH="$PATH:$HOME/development/node/bin"
MODE="${1:-}"

if [ "$MODE" != "--build-only" ] && ! command -v firebase >/dev/null; then
  echo "The Firebase CLI isn't installed. Install it with:" >&2
  echo "  curl -sL https://firebase.tools | bash" >&2
  echo "then sign in with: firebase login" >&2
  exit 1
fi

if [ "$MODE" != "--skip-build" ]; then
  ./scripts/build_web.sh
fi

if [ "$MODE" = "--build-only" ]; then
  echo "==> Not deployed."
  exit 0
fi

echo "==> Deploying to Firebase Hosting ($PROJECT)"
firebase deploy --only hosting --project "$PROJECT"

echo
echo "Live:"
echo "  Resident app:  https://$PROJECT.web.app"
echo "  Admin portal:  https://$PROJECT.web.app/admin/"
echo "  Responders:    https://$PROJECT.web.app/responder/"
