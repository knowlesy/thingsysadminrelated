#REF https://ghostpi.pro/cloudflare-ddns-raspberry-pi/
# use code below errors on main page for final script 
# crontab
# */59 * * * * /scripts/cfddns.sh >/dev/null >> /logs/cloud.log 2>&1

#!/bin/sh

[ ! -f /scripts/current_ip.txt ] && touch /scripts/currentip.txt

NEWIP=$(curl icanhazip.com)
CURRENTIP='cat /scripts/currentip.txt'

if [ "$NEWIP" = "$CURRENTIP" ]
then
  echo "IP address unchanged"
else
  curl -X PUT "https://api.cloudflare.com/client/v4/zones/<zoneid>/dns_records/<recordid>" \
    -H "X-Auth-Email: name@email.com" \
    -H "X-Auth-Key: <apikey>" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"123.domain.net\",\"content\":\"$NEWIP\"}"
  echo $NEWIP > /scripts/currentip.txt
fi
