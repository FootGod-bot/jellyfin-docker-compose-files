UPDATE_DUCKDNS() {
URL=$1
TOKEN=token
echo ""
echo "Updating $URL.duckdns.org"
echo url="https://www.duckdns.org/update?domains=$URL&token=$TOKEN&ip=" | curl -k -o ~/duckdns/duck.log -K -
echo "Logs:"
cat /root/duckdns/duck.log
}



UPDATE_DUCKDNS "YPUR_SUB_DOMAIN"
