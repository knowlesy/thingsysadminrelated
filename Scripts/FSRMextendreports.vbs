#Notmycode! 

********************************************************
const scriptName = "fsrmReportLimit"
DIM limitNames
limitNames = Array("MaxFiles", "MaxFileGroups", "MaxFileOwners", "MaxFilesPerFileGroup", "MaxFilesPerFileOwner", "MaxFilesPerDuplGroup",
"MaxDuplicateGroups", "MaxQuotas", "MaxFileScreenEvents")
const optLimit = "/limit"
const optValue = "/value"
DIM objArgs, fsrm, strLimitName, strLimitValue
set objArgs = wscript.Arguments 
if objArgs.count = 0 then
    PrintUsage()
    wscript.quit
end if
if objArgs.count = 1 then
    if objArgs(0) = "/?" then
        PrintUsage()
        wscript.quit
    end if
end if
DIM i, j
DIM strOption, strNewOption
DIM nModifyProperties
nModifyProperties = 0
for i = 0 to objArgs.count-1
    if (LCase(objArgs(i)) = optLimit) then
        strLimitName = objArgs(i+1)
        i = i + 1
    elseif (LCase(objArgs(i)) = optValue) then
        strLimitValue = objArgs(i+1)
        i = i + 1
    else
        wscript.echo "Error: invalid argument, " & objArgs(i)
        PrintUsage()
        wscript.quit
    end if
next
DIM limitNameCode
limitNameCode = -1
for i = LBound(limitNames) to UBound(limitNames)
    if (LCase(strLimitName) = LCase(limitNames(i))) then
  limitNameCode = i + 1
  exit for
    end if
next
if (limitNameCode = -1) then
    wscript.echo "Error: invalid limit name, " & strLimitName
    PrintUsage()
    wscript.quit
end if
set fsrm = WScript.createobject("fsrm.FsrmReportManager")
DIM newLimit
call fsrm.SetReportSizeLimit(limitNameCode, strLimitValue)
newLimit = fsrm.GetReportSizeLimit(limitNameCode)
if (Int(newLimit) = Int(strLimitValue)) then
    wscript.echo "Report size limit " & limitNames(limitNameCode - 1) & " was changed to " & strLimitValue
else
    wscript.echo "unable to change limit " & limitNames(limitNameCode - 1) & ".  Limit is set to " & newLimit
end if
function PrintUsage()
wscript.echo ""
wscript.echo scriptName & "  /limit <name> [/value <value>"
wscript.echo "         <name>  - name of the report size limit to modify"
wscript.echo "         <value> - new value for the size limit"
wscript.echo ""
wscript.echo "Report limit values:"
for i = LBound(limitNames) to UBound(limitNames)
    wscript.echo "    " & limitNames(i)
next
end function
