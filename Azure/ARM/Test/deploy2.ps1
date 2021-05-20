$temp = ".\tagsexample.json"
$who = read-host "Enter Customer"
$who = $who.Remove(" ","")
$sla = read-host "Enter SLA"
$sla = $sla.Remove(" ","")
$date = get-date -Format yyyy-MM-dd-hh-mm
$deployment = ($date + '_' + $who)
$creator = Get-AzContext
$customerbillingcode = "1234-$who"
$projectcode = "Test_Deployment_For_$who"
$batch = "1","2","3","4"
$batchselection = Get-Random $batch
$resourceGroupName = ('rg-uat-vm-' + $who + '-application-1') 
New-AzResourceGroupDeployment -Name $deployment -ResourceGroupName $resourceGroupName -TemplateFile $temp -user $creator.account `
 -custbc $customerbillingcode -location 'uksouth' `
 -projectc $projectcode `
 -pend $date.AddMonths(6) `
 -review $date.AddMonths(3) `
 -updatebatch $batchselection `
 -sla $sla `
-customer $who
