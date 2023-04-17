# https://github.com/zechnkaas/powershellscripts
# Script for testing Event monitoring on all DC servers (event forwarding / Sentinel Events / etc. )
# run pretest beforehand to check if all servers are up and working
# run with enterprise Admin, can be run on any of our forests

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

function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int] $length
    )
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
    $rng.GetBytes($bytes)
    $result = New-Object char[]($length)
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
    return (-join $result)
}

$starttime = Get-Date

$auditnr   = "1"
$waittime  = 5

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

"Creating Audit events" | dl

foreach($domain in $ADForest.Domains){
    "Doing: " + $domain | dl -color Cyan
    foreach($dc in $domain.DomainControllers){
        $dc.name | dl -color green
        $path = "CN=Users,DC=" + $Domain.ToString().replace(".",",DC=")
        "creating group" | dl -color DarkYellow
        New-ADGroup -Server $dc.Name -Name ("Audit$auditnr " + $dc.Name.Substring(0,$dc.Name.IndexOf("."))) -Path $path -GroupScope DomainLocal
        Start-Sleep -Seconds $waittime
        "get group" | dl -color DarkYellow
        $adgroup = Get-ADGroup -Server $dc.Name -Identity ("Audit$auditnr " + $dc.Name.Substring(0,$dc.Name.IndexOf(".")))
        Start-Sleep -Seconds $waittime
        $upnsuffix = $domain.Name
        $password = Get-RandomPassword 32
        $pw       = (ConvertTo-SecureString -AsPlainText $password -Force)
        $name     = "Audit$auditnr - " + $dc.Name.Substring(0,$dc.Name.IndexOf("."))
        $givenn   = $dc.Name.Substring(0,$dc.Name.IndexOf("."))
        $surn     = "Audit$auditnr"
        $samacc   = "audit$auditnr-" + $dc.Name.Substring(0,$dc.Name.IndexOf("."))
        $upn      = $samacc + "@" + $upnsuffix
        "creating user" | dl -color DarkYellow
        New-ADUser -Server $dc.Name -Enabled $false -AccountPassword $pw -GivenName $givenn -Surname $surn -DisplayName $name -Name $name -Path $path -UserPrincipalName $upn -SamAccountName $samacc
        Start-Sleep -Seconds $waittime
        "get user" | dl -color DarkYellow
        $useracc  = Get-ADUser -Server $dc.Name -Identity $samacc
        "add user to group" | dl -color DarkYellow
        $adgroup | Add-ADGroupMember -Server $dc.Name -Members $useracc 
        "reset password" | dl -color DarkYellow
        $useracc | Set-ADAccountPassword -Server $dc.Name -NewPassword (ConvertTo-SecureString -AsPlainText (Get-RandomPassword 32) -Force)
        Start-Sleep -Seconds $waittime
        "remove user from group" | dl -color DarkYellow
        $adgroup | Remove-ADGroupMember -Server $dc.Name -Members $useracc -Confirm:$false
        Start-Sleep -Seconds $waittime
        "delete user" | dl -color DarkYellow
        $useracc | Remove-ADUser -Server $dc.Name -Confirm:$false
        "delete group" | dl -color DarkYellow
        $adgroup | Remove-ADGroup -Server $dc.Name -Confirm:$false
    }
}