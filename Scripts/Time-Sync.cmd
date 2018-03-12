net time /setsntp:"0.uk.pool.ntp.org 1.uk.pool.ntp.org 2.uk.pool.ntp.org 3.uk.pool.ntp.org"
w32tm /query /peers
net stop w32time
net start w32time
w32tm /resync
w32tm /query /peers
pause
