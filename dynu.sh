UPDATE_DYNU() {
  HOSTNAME="$1"
  USERNAME="your_dynu_username"
  PASSWORD="your_dynu_password"

  LOGFILE="$HOME/dynu/dynu.log"
  mkdir -p "$HOME/dynu"

  echo "Updating Dynu hostname: $HOSTNAME"

  curl -s "https://api.dynu.com/nic/update?hostname=${HOSTNAME}&myip=" \
    --user "${USERNAME}:${PASSWORD}" \
    -o "$LOGFILE"

  echo "Logs:"
  cat "$LOGFILE"
}

UPDATE_DYNU "your-hostname.dynu.com"
