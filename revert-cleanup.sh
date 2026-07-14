#!/usr/bin/env bash
# Undo ./cleanup-macos.sh: re-enable every launch agent it disabled and restore
# the script-set telemetry default. (The declarative defaults in configuration.nix
# revert by removing them there and running ./rebuild.sh. Removed bundled apps
# come back from the App Store.)
set -uo pipefail

UID_NUM="$(id -u)"

AGENTS=(
  # analytics
  com.apple.ap.adprivacyd
  com.apple.ap.promotedcontentd
  com.apple.geoanalyticsd
  com.apple.inputanalyticsd
  com.apple.UsageTrackingAgent
  com.apple.triald
  com.apple.duetexpertd
  # siri
  com.apple.assistantd
  com.apple.Siri.agent
  com.apple.assistant_service
  com.apple.siriactionsd
  com.apple.SiriTTSTrainingAgent
  com.apple.voicebankingd
  # icloud photos + analysis
  com.apple.cloudphotod
  com.apple.photoanalysisd
  com.apple.mediaanalysisd
)

echo "==> Re-enabling launch agents"
for label in "${AGENTS[@]}"; do
  if launchctl enable "gui/${UID_NUM}/${label}" 2>/dev/null; then
    echo "  enabled: $label"
  else
    echo "  (nothing to do): $label"
  fi
done

echo "==> Restoring diagnostics auto-submit (sudo)"
sudo defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool true 2>/dev/null \
  && echo "  restored" || echo "  (could not write diagnostics plist)"

cat <<'EOF'

Done. Log out / reboot for the agents to relaunch.
Note: the telemetry/Siri `defaults` set declaratively in configuration.nix are
still applied - remove those blocks and run ./rebuild.sh to fully revert them.
EOF
