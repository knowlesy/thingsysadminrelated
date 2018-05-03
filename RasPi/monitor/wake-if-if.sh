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
   sudo etherwake -i eth0 00:00:00:00:00:00
   curl -u o.<api>: https://api.pushbullet.com/v2/pushes -d type=note -d title="Server" -d body="Host Powered on"
    fi
else
  echo "$HOST didn't reply"
fi
