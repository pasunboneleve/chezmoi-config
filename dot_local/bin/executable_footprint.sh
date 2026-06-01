#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
footprint.sh collects a lightweight public footprint report for a domain.

Use it for first-pass reconnaissance of domains you are allowed to inspect:
DNS records, common subdomains, certificate-transparency names, HTTP headers,
the first HTML response, linked JavaScript bundles, and URLs or infrastructure
fingerprints found inside downloaded JavaScript.

It is meant for passive or low-volume inspection. It does not brute-force
subdomains, authenticate, submit forms, fuzz endpoints, or scan ports.

Usage: footprint.sh DOMAIN [APP_HOST]

DOMAIN is the registrable domain to probe, such as example.com.au.
APP_HOST is optional and defaults to DOMAIN. Use it when the web app lives on
a specific host, such as portal.example.com.au.

Reports are written under /tmp/DOMAIN-footprint-UTC_TIMESTAMP/.
Required tools: bash, dig, curl, jq, whois, timeout, grep, sed, sort, find.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 2
fi

DOMAIN="${1#http://}"
DOMAIN="${DOMAIN#https://}"
DOMAIN="${DOMAIN%%/*}"
DOMAIN="${DOMAIN%.}"

APP_HOST="${2:-$DOMAIN}"
APP_HOST="${APP_HOST#http://}"
APP_HOST="${APP_HOST#https://}"
APP_HOST="${APP_HOST%%/*}"
APP_HOST="${APP_HOST%.}"

if [[ -z "$DOMAIN" || "$DOMAIN" == *[!A-Za-z0-9.-]* || "$DOMAIN" != *.* ]]; then
  echo "Invalid DOMAIN: ${1:-}" >&2
  usage
  exit 2
fi

if [[ -z "$APP_HOST" || "$APP_HOST" == *[!A-Za-z0-9.-]* || "$APP_HOST" != *.* ]]; then
  echo "Invalid APP_HOST: ${2:-$APP_HOST}" >&2
  usage
  exit 2
fi

RUN_LABEL="${DOMAIN//[^A-Za-z0-9._-]/-}"

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="/tmp/$RUN_LABEL-footprint-$RUN_ID"
JS_DIR="$OUT_DIR/js"
REPORT="$OUT_DIR/report.txt"
DIG_OPTS=(+time=5 +tries=1)
CURL_OPTS=(-sS --connect-timeout 10 --max-time 30)

mkdir -p "$JS_DIR"

section() {
  {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
  } >> "$REPORT"
}

run() {
  local label="$1"
  shift
  section "$label"
  {
    echo "\$ $*"
    "$@" 2>&1 || true
  } >> "$REPORT"
}

echo "Public footprint probe" > "$REPORT"
echo "Domain: $DOMAIN" >> "$REPORT"
echo "App host: $APP_HOST" >> "$REPORT"
echo "Run UTC: $RUN_ID" >> "$REPORT"
echo "Output dir: $OUT_DIR" >> "$REPORT"

section "Resolved public IP WHOIS"
{
  echo "\$ dig ${DIG_OPTS[*]} +short A $DOMAIN | tail -n1"
  ip="$(dig "${DIG_OPTS[@]}" +short A "$DOMAIN" | tail -n1 || true)"

  if [[ -n "$ip" ]]; then
    echo "IP: $ip"
    echo "\$ timeout 20s whois $ip"
    timeout 20s whois "$ip" 2>&1 || true
  else
    echo "No A record found."
  fi
} >> "$REPORT"

run "DNS: NS" dig "${DIG_OPTS[@]}" NS "$DOMAIN" +short
run "DNS: A" dig "${DIG_OPTS[@]}" A "$DOMAIN" +short
run "DNS: www CNAME" dig "${DIG_OPTS[@]}" CNAME "www.$DOMAIN" +short
run "DNS: TXT" dig "${DIG_OPTS[@]}" TXT "$DOMAIN" +short

section "Common subdomains"
for s in app api staging dev admin portal www auth login irys client supplier staff employee forms learn status trust directus messina palermo venice corsica; do
  {
    echo "== $s =="
    dig "${DIG_OPTS[@]}" +short "$s.$DOMAIN" 2>&1 || true
  } >> "$REPORT"
done

section "Certificate transparency names"
CRT_FILE="$OUT_DIR/crtsh-names.txt"
curl "${CURL_OPTS[@]}" -fsSL "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>> "$REPORT" \
  | jq -r '.[].name_value' 2>> "$REPORT" \
  | sort -u \
  > "$CRT_FILE" || true

cat "$CRT_FILE" >> "$REPORT" 2>/dev/null || true

run "HTTP headers: app host" curl "${CURL_OPTS[@]}" -I "https://$APP_HOST"

section "HTML head: app host"
HTML_FILE="$OUT_DIR/${APP_HOST}.html"
curl "${CURL_OPTS[@]}" -fsSL "https://$APP_HOST" -o "$HTML_FILE" 2>> "$REPORT" || true
head -80 "$HTML_FILE" >> "$REPORT" 2>/dev/null || true

section "Download JavaScript bundles"
{ grep -oE 'src="[^"]+\.js[^"]*"' "$HTML_FILE" 2>/dev/null || true; } \
  | sed 's/src="//;s/"$//' \
  | sort -u \
  | while read -r f; do
      case "$f" in
        http*) url="$f" ;;
        /*) url="https://$APP_HOST$f" ;;
        *) url="https://$APP_HOST/$f" ;;
      esac

      filename="$(basename "$f" | cut -d '?' -f1)"
      echo "$url -> $JS_DIR/$filename" >> "$REPORT"
      curl "${CURL_OPTS[@]}" -fsSL "$url" -o "$JS_DIR/$filename" 2>> "$REPORT" || true
    done

section "URLs found inside JavaScript"
grep -RhoE 'https?://[^"'\'' )]+' "$JS_DIR" 2>/dev/null \
  | sort -u \
  > "$OUT_DIR/js-urls.txt" || true
cat "$OUT_DIR/js-urls.txt" >> "$REPORT" 2>/dev/null || true

section "Infrastructure fingerprints inside JavaScript"
grep -RhiE 'api|graphql|auth|cognito|execute-api|firebase|supabase|sentry|datadog|segment|intercom|stripe|mixpanel|amplitude|launchdarkly|posthog|okta|auth0|azure|b2c|cloudfront|s3|lambda|apigateway|rollbar|newrelic|honeycomb|openai|anthropic|llm|rag|vector|embedding' "$JS_DIR" 2>/dev/null \
  | head -300 \
  > "$OUT_DIR/js-fingerprints.txt" || true
cat "$OUT_DIR/js-fingerprints.txt" >> "$REPORT" 2>/dev/null || true

section "Downloaded JS files"
find "$JS_DIR" -maxdepth 1 -type f -printf '%f\t%k KB\n' | sort >> "$REPORT" || true

echo
echo "Saved report:"
echo "$REPORT"
echo
echo "Saved files:"
find "$OUT_DIR" -maxdepth 2 -type f | sort
