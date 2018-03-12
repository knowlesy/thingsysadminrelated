showip=$(curl icanhazip.com)
curl -u <api>: https://api.pushbullet.com/v2/pushes -d type=note -d title="External IP Today" -d body=$showip
exit 0
