Import-Module AZ

$loggedon = [string]::IsNullOrEmpty($(Get-AZContext).Account)

if($loggedon){
    Connect-AzAccount
    } else {
    "already logged on: " + (Get-AzContext).Account
}

$subscriptions = Get-AzSubscription
$result = @()

foreach($subs in $subscriptions){
$subs.Name
    Set-AzContext -SubscriptionId $subs.Id
$networks = Get-AzVirtualNetwork


    foreach($net in $networks){

    $Name   = $net.Name
    $subnet = ""
    

        foreach($addressrange in $net.AddressSpace.AddressPrefixes){
        $type = "Virtual Network"

            $prop = @{
            VirtualNetwork = $Name
            Subscription   = $subs.Name
            Type           = $type
            SubnetName     = $subnet
            AddressRange   = $addressrange
            }
        $result += New-Object psobject -Property $prop | select VirtualNetwork, Subscription, Type, SubnetName, AddressRange
        }

        foreach($subn in $net.Subnets){
        $subnet = $subn.name
        $type   = "Subnet"
    
            $prop = @{
            VirtualNetwork = $Name
            Subscription   = $subs.Name
            Type           = $type
            SubnetName     = $subnet
            AddressRange   = $subn.AddressPrefix[0]
            }
        $result += New-Object psobject -Property $prop | select VirtualNetwork, Subscription, Type, SubnetName, AddressRange
        }
    }
}

$result | Out-GridView