#todays date for the file name
$datestring = (Get-Date -DisplayHint Date).ToString("s").Replace(":","-") 
#Set file name date / time 
$file = "$datestring.txt" 
#Unique ID for files - comparing restores 
$id = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join ''

#Create files
New-Item -type file "a:\test\$file" 
New-Item -type file "e:\test\$file" 
New-Item -type file "f:\test\$file" 
New-Item -type file "g:\test\$file" 
New-Item -type file "h:\test\$file" 
New-Item -type file "j:\test\$file" 
New-Item -type file "k:\test\$file" 
New-Item -type file "l:\test\$file" 
New-Item -type file "u:\test\$file" 
New-Item -type file "y:\test\$file" 

#Create Random ID for inside the file
$id | out-file -FilePath "a:\test\$file" 
$id | out-file -FilePath "e:\test\$file" 
$id  | out-file -FilePath "f:\test\$file" 
$id  | out-file -FilePath "g:\test\$file" 
$id  | out-file -FilePath "h:\test\$file" 
$id  | out-file -FilePath "j:\test\$file" 
$id  | out-file -FilePath "k:\test\$file" 
$id  | out-file -FilePath "l:\test\$file" 
$id  | out-file -FilePath "u:\test\$file" 
$id  | out-file -FilePath "y:\test\$file" 
							
							
							
							
							
							
							
							
							
							
							
