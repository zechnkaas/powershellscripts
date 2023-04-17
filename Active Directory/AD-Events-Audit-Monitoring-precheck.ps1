# https://github.com/zechnkaas/powershellscripts
# run this script beforehand to check if every Domaincontroller is accessible
# run with enterprise admin to have access on all servers
# can be run in all forests (DNSAdmin Groups has no localization name it is alyways the same)
# if a server fails check if reachable or AD webservices are running

$Global:prevtime = Get-Date

Function dl {
    param([Parameter(ValueFromPipeline=$true)]$pip, $color)
    if($null -eq $color) {
    $color = "White" }
    $logtime = (get-date) - $starttime
    $logtime2 = (get-date) - $global:prevtime
    $writeline = "{0:G}" -f $logtime + " {0:G}" -f $logtime2 +" "+ $pip

    Write-Host $writeline -ForegroundColor $color
    $global:prevtime = Get-Date
}

$starttime = Get-Date

"starting" | dl
"Read Domain Infos" | dl
$ADForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()

"Get total count of DCs in forest" | dl
$count = 0
foreach($domain in $ADForest.Domains){
#    "Doing: " + $domain | dl
    foreach($dc in $domain.DomainControllers){
#        $dc.name | dl
        $count++
   }
}
$count

"trying to read from all DCs" | dl

foreach($domain in $ADForest.Domains){
    "Doing: " + $domain | dl -color Cyan
    # if($domain.name -like "bwt.at.bwt-group.com"){break}

    foreach($dc in $domain.DomainControllers){
        $dc.name | dl -color green
        "get DNSAdmin group" | dl -color DarkYellow
        $useracc  = Get-ADGroup -Server $dc.Name -Identity DNSAdmins
    }
}