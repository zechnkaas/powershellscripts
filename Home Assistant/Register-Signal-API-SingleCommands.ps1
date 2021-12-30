###################################################
# https://github.com/zechnkaas/powershellscripts/ #
###################################################
#Requires -Version 3.0
"'Requires minimum version 3.0"
"Running PowerShell $($PSVersionTable.PSVersion)."

#Either run interactively in ISE or copy paste to a powershell session

$apiurl       = "http://192.168.1.1:8080" # URL of API, in case of Homeassistant it is the HA IP and default port is 8080
$phonenumber  = "+43xxxxxxxxx"            # International format (+43xxxxxxxxx)

Invoke-RestMethod -Method Post -ContentType "application/json" -Uri ($apiurl + "/v1/register/" + $phonenumber)

$verifycode   = "xxx-xxx"                 # Enter verifycode here with the - like 123-456

Invoke-RestMethod -Method Post -ContentType "application/json" -Uri ($apiurl + "/v1/register/" + $phonenumber + "/verify/" + $verifycode)

# Code in case you have to deal with the captcha
# Open webite https://signalcaptchas.org/registration/generate.html and enter developer tools (F12 for Crome & IE) The console tab is what you are looking for
# sample picture here https:// this is what you should see after resolving the captcha

$captchatoken = "damnlongstring"          # paste captcha token here after you have resolved it

$data = @"
{"captcha": "$captchatoken"}
"@

Invoke-RestMethod -Method Post -ContentType "application/json" -Uri ($apiurl + "/v1/register/" + $phonenumber) -Body $data

Invoke-RestMethod -Method Post -ContentType "application/json" -Uri ($apiurl + "/v1/register/" + $phonenumber + "/verify/" + $verifycode)

# If you like to test the API and send a message

$recipient    = "+432xxxxxxx"            # Recipient phone number international format (+43xxxxxxxxx)
$message      = "Test message"


$data = @"
{"message": "$message","number": "$phonenumber","recipients" : ["$recipient"]}
"@

Invoke-RestMethod -Method Post -ContentType "application/json" -Uri ($apiurl + "/v2/send") -Body $data

# check about

Invoke-RestMethod -ContentType "application/json" -Uri ($apiurl +  "/v1/about")
