$isthisavirtualbeast = get-wmiobject -computer localhost win32_computersystem | select-object -ExpandProperty Model
if ($isthisavirtualbeast -match "Virtual")
{

}
else
{

}
