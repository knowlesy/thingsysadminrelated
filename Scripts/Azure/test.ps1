<#
Currency code	Detail
USD	US dollar
AUD	Australian dollar
BRL	Brazilian real
CAD	Canadian dollar
CHF	Swiss franc
CNY	Chinese yuan
DKK	Danish krone
EUR	Euro
GBP	British pound
INR	Indian rupee
JPY	Japanese yen
KRW	Korean won
NOK	Norwegian krone
NZD	New Zealand dollar
RUB	Russian ruble
SEK	Swedish krona
TWD	Taiwan dollar

#>


$url = "https://prices.azure.com/api/retail/prices"
$filter = 'Virtual Machines'
$price = 'GBP'
$combined = ($url + "?currencyCode='" + $price + "'&$filter=serviceFamily eq" + $filter)
#$combined = ($url + "?currencyCode='" + $price )
$date = Get-Date -format yyyy-MM-dd-HHmmss
#$filter = $filter.Replace(" ","")
$csvexport = ('c:\temp\' + $date + '_Azure_'+ $filter + '.csv')
Invoke-RestMethod -Uri $combined # | Select-Object -ExpandProperty items | Export-Csv $csvexport -Append -NoClobber -NoType
Invoke-RestMethod -Uri $combined  | select NextPageLink



####testing

$url = "https://prices.azure.com/api/retail/prices"
$filter = 'Virtual Machines'
$price = 'GBP'
$combined = ($url + "?currencyCode='" + $price + "'&$filter=serviceFamily eq" + $filter)
#$combined = ($url + "?currencyCode='" + $price )
$date = Get-Date -format yyyy-MM-dd-HHmmss
#$filter = $filter.Replace(" ","")
$i = 0
do {
    $test = Invoke-RestMethod -Uri $combined | select -Unique NextPageLink
    $test.NextPageLink
    $combined = Invoke-RestMethod -Uri $test.NextPageLink | select -Unique NextPageLink
    $combined.NextPageLink
    $i++
} until ($i -eq 4)

