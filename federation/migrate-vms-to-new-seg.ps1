Connect-VIServer -Server vcsa-01a.corp.local -user administrator@vsphere.local -Password VMware1!
$WEBOLD="ov-web"
$DBOLD="ov-db"
$WEBNEW="ov-web-stretched"
$DBNEW="ov-db-stretched"
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $WEBOLD } |Set-NetworkAdapter -Portgroup $WEBNEW -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $DBOLD } |Set-NetworkAdapter -Portgroup $DBNEW -Confirm:$false
