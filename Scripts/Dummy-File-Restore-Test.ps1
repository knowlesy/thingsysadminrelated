#todays date for the file name
$datestring = (Get-Date -DisplayHint Date).ToString("s").Replace(":","-") 
#Set file name date / time 
$file = "$datestring.txt" 
#Unique ID for files - comparing restores 
$id = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join ''

#Create files
New-Item -type file "a:\test\a-$file" 
New-Item -type file "e:\test\e-$file" 
New-Item -type file "f:\test\f-$file" 
New-Item -type file "g:\test\g-$file" 
New-Item -type file "h:\test\h-$file" 
New-Item -type file "j:\test\j-$file" 
New-Item -type file "k:\test\k-$file" 
New-Item -type file "l:\test\l-$file" 
New-Item -type file "u:\test\u-$file" 
New-Item -type file "y:\test\y-$file" 

#Create Random ID for inside the file
$id | out-file -FilePath "a:\test\a-$file" 
$id | out-file -FilePath "e:\test\e-$file" 
$id  | out-file -FilePath "f:\test\f-$file" 
$id  | out-file -FilePath "g:\test\g-$file" 
$id  | out-file -FilePath "h:\test\h-$file" 
$id  | out-file -FilePath "j:\test\j-$file" 
$id  | out-file -FilePath "k:\test\k-$file" 
$id  | out-file -FilePath "l:\test\l-$file" 
$id  | out-file -FilePath "u:\test\u-$file" 
$id  | out-file -FilePath "y:\test\y-$file" 
							
							
							
							
							
							
							
							
							
							
							
