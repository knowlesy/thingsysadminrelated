#2 options WOL or DRAC
#DRAC requires apt-get install sshpass and new user that has restricted permissions logi & syscontrol only
#WOL you may need to add a perm ARP in this see http://xmodulo.com/how-to-add-or-remove-static-arp-entry-on-linux.ht$
#!/bin/bash

HOST=192.168.0.2
HOST2=192.168.0.3

ping -c1 $HOST 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]
then
  echo "$HOST has replied"
  ping -c1 $HOST2 1>/dev/null 2>/dev/null
  SUCCESS2=$?
  if [ $SUCCESS2 -eq 0 ]
  then
    echo "$HOST and $HOST2 has replied"
  else
   echo "Powering on $HOST2"
   # WOL Option
   sudo etherwake -i eth0 00:00:00:00:00:00
   # SSH and power on Dell Server
   #sshpass -p "<PASSWORD>" ssh -o StrictHostKeyChecking=no <username>@192.168.0.4 racadm serveraction powerup
   sleep 4m
   ping -c1 $HOST2 1>/dev/null 2>/dev/null
   SUCCESS3=$?
   if [ $SUCCESS3 -eq 0 ]
    then
     curl -u o.<api>: https://api.pushbullet.com/v2/pushes -d type=note -d title="Server" -d body="Host Powered on"
     else
        echo "No response within 4 minutes for $HOST2"
    fi
  fi

else
  echo "$HOST didn't reply"
fi
