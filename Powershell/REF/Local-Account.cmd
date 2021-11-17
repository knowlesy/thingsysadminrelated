@echo off
net user <LOCAL USER> <PASS> /add /comment:"Local administrator" /passwordchg:NO
wmic useraccount where "name='<LOCAL USER>'" set passwordexpires=FALSE
net localgroup "Administrators" <LOCAL USER>/add
exit