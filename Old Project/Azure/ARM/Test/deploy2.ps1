$temp = ".\test7.json"
$who = read-host "Enter Customer"
$sla = read-host "Enter SLA"
$date = get-date
$datestring = $date.ToString("yyyyMMddhhmm")
$deployment = ($datestring + $who)
$creator = Get-AzContext
$customerbillingcode = "1234-$who"
$projectcode = "Test_Deployment_For_$who"
$batch = "1","2","3","4"
$batchselection = Get-Random $batch
$resourceGroupName = ('rg-uat-vm-' + $who + '-application-1')
$location = 'uksouth'
$6months = $date.AddMonths(6)
$3months = $date.AddMonths(3)
$projectenddate = $6months.ToString("yyyyMMddhhmm")
$reviewdate = $3months.ToString("yyyyMMddhhmm")
New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -Name $deployment -ResourceGroupName $resourceGroupName -TemplateFile $temp -user $creator.account `
    -custbc $customerbillingcode -location $location `
 -projectc $projectcode `
 -pend $projectenddate `
 -review $reviewdate `
 -updatebatch $batchselection `
 -sla $sla `
    -customer $who -timec $datestring
