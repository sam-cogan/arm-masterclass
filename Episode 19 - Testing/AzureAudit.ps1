param(
    
    [Parameter(Mandatory)]
    
    [ValidateNotNullOrEmpty()]
    
    [string]$ResourceGroupName

)
    

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Split-Path -Leaf $here

Describe "Virtual Machine Tests" {

    $VMs = Get-AzVM -ResourceGroupName $ResourceGroupName

    Context "Antivirus" {

        foreach ($vm in $vms) {

            $avExtension = Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $vm.name -Name IaaSAntimalware
            $publicSettings = ConvertFrom-Json $avExtension.PublicSettings

            It "$($vm.name) Should Have Micrsoft Antimalware Extension Installed" {
                
                $avExtension | Should Not Be $null
                $avExtension.ProvisioningState | Should Be "Succeeded"
                $publicSettings.AntimalwareEnabled | Should Be "True"
            }

            It "$($vm.name) Should Have Real Time Protection Enabled" {
                $publicSettings.RealtimeProtectionEnabled | Should Be "true"
            }
        }

    }

    Context "VM Network Security Groups" {

        foreach ($vm in $vms) {
            
            foreach ($nicID in $vm.NetworkProfile.NetworkInterfaces) {
                $Nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | where { $_.Id -eq $nicID.id }
                $nicNSG = $nic.NetworkSecurityGroup 
                $subnet = $nic.IpConfigurations.subnet
                $VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName | Where { $_.Subnets.ID -match $subnet.id }
                $subnetNSG = $($VirtualNetwork.Subnets | Where { $_.ID -match $subnet.id }).NetworkSecurityGroup
            
                It "$($vm.name) NIC $($nicID.name) Should Have an NSG Enabled" {
                    ($nicNSG -eq $null) -and ($subnetNSG -eq $null)| Should Not Be $true
                }
            
            }
            
        }
    }

    Context "VM Bitlocker Encryption" {
        foreach ($vm in $vms) {
            $encryptionStatus = Get-AzVMDiskEncryptionStatus -ResourceGroupName $resourcegroupname -VMName $vm.name
        
            It "$($vm.name)  Should have an encrypted OS disk" {
                $encryptionStatus.OsVolumeEncrypted | should be "Encrypted"
            }

            It "$($vm.name)  Should have encrypted Data disks" {
                $encryptionStatus.DataVolumesEncrypted | should be "Encrypted"
            }

        }

    }
}

Describe "Network Security Group Tests" {

    $NSGS = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName
    
    Context "Ports Open to All" {
        foreach ($NSG in $NSGS) {
            $openAllCount = 0
            foreach ($rule in $NSG.SecurityRules) {
                if ($rule.Direction -eq "Inbound" -and $rule.SourceAddressPrefix -eq "*") {
                    $openAllCount ++
                }
            }
            It "$($NSG.name) Should Have no inbound rules open to all" {
                $openAllCount| Should Be 0
            }
        }

    }

}


Describe "Storage Account Tests" {
    $storageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName

    foreach ($storageAccount in $storageAccounts) {
        It "$($storageAccount.StorageAccountName )  Should have encrypted blob storage" {
            $storageAccount.Encryption.Services.Blob.enabled | should be $true
        }
    }

}


Describe "Azure SQL Tests" {
    $sqlServers = Get-AzSqlServer -ResourceGroupName $ResourceGroupName
    foreach ($sqlserver in $sqlServers) {
        $sqlDatabases = Get-AzSqlDatabase -ServerName $sqlServer.ServerName -ResourceGroupName $ResourceGroupName

        foreach ($sqlDatabase in $sqlDatabases) {
            if ($sqlDatabase.databaseName -ne "Master") {
                $tdeStatus = Get-AzSqlDatabaseTransparentDataEncryption -ServerName $sqlserver.ServerName -DatabaseName $sqlDatabase.databaseName -ResourceGroupName $ResourceGroupName
                $threatDetectionStatus = Get-AzSqlDatabaseThreatDetectionPolicy -ServerName $sqlserver.ServerName -DatabaseName $sqlDatabase.databaseName -ResourceGroupName $ResourceGroupName
                It "$($sqlDatabase.DatabaseName) on server $($sqlServer.serverName)  Should have TDE Enabled" {
                    $tdeStatus.State| should be "Enabled"
                }

                It "$($sqlDatabase.DatabaseName) on server $($sqlServer.serverName)  Should have Threat Detection Enabled" {
                    $threatDetectionStatus.ThreatDetectionState| should be "Enabled"
                }
            }
        }
    }

}




