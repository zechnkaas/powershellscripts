# enter your license key at the $lickey variable
# and change the $dir variable if you run this script interactivly. 
# if you run it directly it will place all files in the same folder
# Put 7-Zip Folder into the same folder as the script to be able to exctract the Files and uncomment the 7zip parts
Function dl {
    param([Parameter(ValueFromPipeline=$true)]$pip, $par)
    $logtime = (get-date) - $starttime
    Write-Host ("{0:G}" -f $logtime) $pip -ForegroundColor Yellow}

$starttime = Get-Date
$update    = $false

"starting" | dl 

# if you run this script interactivly in powersell ise or visual studio code
# change the $dir variable to the script path this is where the files are beein downloaded
# and extracted
if($PSScriptRoot){
    "starting scripted" | dl
    $dir = $PSScriptRoot
    } else {
    "starting interactive" | dl
    $dir = "$env:APPDATA\"
    }

"check if there is a update available" | dl
# enter License Key here
$lickey = "yourlickey"
# GeoLite ASN CSV
$url    = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=$lickey&suffix=zip"
# GeoLite Citly CSV
#$url    = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=$lickey&suffix=zip"
# GeoLite Country CSV
#$url    = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=$lickey&suffix=zip"
$check  = Invoke-WebRequest -Uri $url -Method Head

# Uncomment if you like to have them extracted too.
#Set-Alias 7z ($dir + "\7-zip\7z.exe")

$lastmodifiedfile = ($dir + "\lastmodified.xml")

"check for previous datefile" | dl
if(Test-Path -Path $lastmodifiedfile){
    "previous datefile file exists, check if content needs to updated" | dl
    $lastchanged = Import-Clixml -path $lastmodifiedfile -ErrorAction SilentlyContinue
        if($lastchanged -lt ($check.Headers.'Last-Modified' | get-date) ){
        "update is available" | dl
        $update = $true
        } else {
        "no updates available" | dl
        }
    (($check.Headers.'Last-Modified') | get-date) | Export-Clixml -Path $lastmodifiedfile
    } else{
    "previous datefile doesn't exists, updating" | dl
    $update = $true
    (($check.Headers.'Last-Modified') | get-date) | Export-Clixml -Path $lastmodifiedfile
    }

    "updatestate is: " + $update | dl

if($update){
    "Downloading" | dl
    $file = $dir + "\" + $check.Headers.'Content-Disposition'.Substring($check.Headers.'Content-Disposition'.IndexOf("=")+1)
    Invoke-WebRequest -Uri $url -OutFile $file
# uncomment to automatically exctract the files and dele the archives
#    "Extracting" | dl
#    7z e $file -o"$dir" -aoa
#    "delete archive" | dl
#    Remove-Item -Path $file
    }

"finished" | dl