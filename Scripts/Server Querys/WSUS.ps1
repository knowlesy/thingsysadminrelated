Get-WsusComputer -All 



$wsusServer = Get-WsusServer | select -first
$wsusSubscription = $wsusServer.GetSubscription()
$selectedProducts = $wsusSubscription.GetUpdateCategories() | Select Title
$selectedClassification = $wsusSubscription.GetUpdateClassifications() | Select Title
$selectedProducts
$selectedClassification 