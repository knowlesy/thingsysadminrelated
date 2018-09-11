Get-GPO -all | Sort ModificationTime -Descending | Select -First 10 | FT DisplayName, ModificationTime
