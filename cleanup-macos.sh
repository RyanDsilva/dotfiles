#!/usr/bin/env bash
# macOS safe-tier cleanup (SIP stays ON, everything reversible via ./revert-cleanup.sh).
#
# Disables analytics/Siri/iCloud-Photos USER launch agents (gui/$UID), writes a
# system telemetry opt-out, and offers to remove unused bundled Apple apps.
# Does NOT touch system daemons and does NOT require disabling SIP.
#
# The declarative telemetry `defaults` (ads, diagnostics, Siri toggles) live in
# configuration.nix and apply on `./rebuild.sh` - this script covers what nix
# can't express: disabling Apple's launch agents + optional app removal.
#
# Run on demand:  ./cleanup-macos.sh    Undo:  ./revert-cleanup.sh
set -uo pipefail

UID_NUM="$(id -u)"

# --- Guard: refuse to ever disable anything that breaks core UX --------------
DO_NOT_DISABLE=(
  com.apple.contactsd            # App Store freezes
  com.apple.AirPlayXPCHelper     # video playback errors
  com.apple.donotdisturbd        # Notification Center breaks
  com.apple.chronod              # widgets break
  com.apple.rapportd             # Continuity / Handoff
  com.apple.rapportd-user
  com.apple.sharingd             # AirDrop / Universal Clipboard
  com.apple.tccd                 # privacy DB
  com.apple.cfprefsd             # preferences
  com.apple.UserEventAgent
  com.apple.cloudd               # core iCloud (Drive/Notes/Passwords need it)
  com.apple.cloudpaird
)

is_guarded() {
  local label="$1"
  for g in "${DO_NOT_DISABLE[@]}"; do
    [ "$label" = "$g" ] && return 0
  done
  return 1
}

# --- Agents to disable (safe tier, user domain, reversible) ------------------
ANALYTICS_AGENTS=(
  com.apple.ap.adprivacyd
  com.apple.ap.promotedcontentd
  com.apple.geoanalyticsd
  com.apple.inputanalyticsd
  com.apple.UsageTrackingAgent
  com.apple.triald
  com.apple.duetexpertd
)
SIRI_AGENTS=(
  com.apple.assistantd
  com.apple.Siri.agent
  com.apple.assistant_service
  com.apple.siriactionsd
  com.apple.SiriTTSTrainingAgent
  com.apple.voicebankingd
)
ICLOUD_PHOTO_AGENTS=(
  com.apple.cloudphotod
  com.apple.photoanalysisd
  com.apple.mediaanalysisd
)

disable_agent() {
  local label="$1"
  if is_guarded "$label"; then
    echo "  SKIP (guarded): $label"
    return
  fi
  launchctl bootout "gui/${UID_NUM}/${label}" 2>/dev/null || true   # stop now
  if launchctl disable "gui/${UID_NUM}/${label}" 2>/dev/null; then  # keep off
    echo "  disabled: $label"
  else
    echo "  (not present / already off): $label"
  fi
}

echo "==> System telemetry opt-out (sudo)"
sudo defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false 2>/dev/null \
  && echo "  diagnostics auto-submit off" || echo "  (could not write diagnostics plist)"

echo "==> Disabling analytics agents"
for a in "${ANALYTICS_AGENTS[@]}"; do disable_agent "$a"; done

echo "==> Disabling Siri agents (Apple Intelligence left ON)"
for a in "${SIRI_AGENTS[@]}"; do disable_agent "$a"; done

echo "==> Disabling iCloud Photos + photo-analysis agents (Drive/Passwords/Notes left ON)"
for a in "${ICLOUD_PHOTO_AGENTS[@]}"; do disable_agent "$a"; done

# --- Optional: remove unused bundled Apple apps (re-downloadable from App Store)
echo
echo "==> Bundled apps (removable - these live in /Applications, not the sealed volume)"
BUNDLED_APPS=( GarageBand iMovie Pages Numbers Keynote )
for app in "${BUNDLED_APPS[@]}"; do
  path="/Applications/${app}.app"
  [ -d "$path" ] || continue
  printf "    Remove %s? [y/N] " "$app"
  read -r reply < /dev/tty
  case "$reply" in
    y|Y)
      sudo rm -rf "$path" && echo "      removed $app (re-install anytime from the App Store)" ;;
    *)
      echo "      kept $app" ;;
  esac
done

# --- Things this script can't safely do: manual toggles ----------------------
cat <<'EOF'

==> Manual steps (not safely scriptable - do these in System Settings):
    Apple ID -> iCloud: turn OFF   Messages in iCloud, Contacts, Calendars,
    Reminders, Safari, Mail.  Keep ON   iCloud Drive, Passwords, Notes.

Done. Reboot to be sure agents stay down, then verify:
    launchctl print-disabled gui/$(id -u) | grep -i 'true'
Undo everything with: ./revert-cleanup.sh
EOF
