#!/usr/bin/env bash
# Builds the resident app (site root), the admin portal (/admin/) and the
# responder portal (/responder/) and deploys them to Vercel as a ready-made
# static site (Vercel can't build Flutter itself).
#
#   ./scripts/deploy_vercel.sh               build, then deploy to production
#   ./scripts/deploy_vercel.sh --skip-build  deploy the existing build/web
#
# First time only: sign in with `vercel login`. The script links this folder
# to the Vercel project VERCEL_PROJECT (default resq-community-safety),
# creating it if needed; the link is saved in .vercel/ (git ignores it).
#
# Hidden files such as .env are never uploaded, so no key reaches the site.
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="${VERCEL_PROJECT:-resq-community-safety}"
# The Vercel CLI installed with npm into ~/development/node.
[ -d "$HOME/development/node/bin" ] && PATH="$PATH:$HOME/development/node/bin"

if ! command -v vercel >/dev/null; then
  echo "The Vercel CLI isn't installed. Install it with:" >&2
  echo "  npm install -g vercel" >&2
  echo "then sign in with: vercel login" >&2
  exit 1
fi
if ! vercel whoami >/dev/null 2>&1; then
  echo "Sign in to Vercel first: vercel login" >&2
  exit 1
fi

if [ "${1:-}" != "--skip-build" ]; then
  ./scripts/build_web.sh
fi

if [ ! -f .vercel/project.json ]; then
  echo "==> Linking this folder to the Vercel project $PROJECT"
  vercel project add "$PROJECT" >/dev/null 2>&1 || true
  vercel link --yes --project "$PROJECT"
fi

echo "==> Packing build/web for Vercel"
rm -rf .vercel/output
mkdir -p .vercel/output/static
rsync -a --exclude='.*' build/web/ .vercel/output/static/
# Files first; then /admin/... and /responder/... open their portals and
# everything else the resident app (all three are single-page apps).
cat > .vercel/output/config.json <<'JSON'
{
  "version": 3,
  "routes": [
    { "handle": "filesystem" },
    { "src": "^/admin(/.*)?$", "dest": "/admin/index.html" },
    { "src": "^/responder(/.*)?$", "dest": "/responder/index.html" },
    { "src": "^/.*$", "dest": "/index.html" }
  ]
}
JSON

echo "==> Deploying to Vercel ($PROJECT, production)"
vercel deploy --prebuilt --prod --yes
