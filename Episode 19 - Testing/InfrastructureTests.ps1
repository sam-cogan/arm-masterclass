$prefix="dev"
$resourceGroup = "dev-rg"

Describe "Resource Group tests" -tag "AzureInfrastructure" {
    
    Context "Resource Groups" {
        It "Check Main Resource Group $resourceGroup Exists" {
            Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue | Should Not be $null
        }
   
    }
}

Describe "Networking Tests" -tag "AzureInfrastructure" {
    Context "Networking" {
        $vNet=Get-AzVirtualNetwork -Name "$prefix-vNet" -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue

        it "Check Virtual Network $prefix-vNet Exists" {
            $vNet | Should Not be $null
        }
            
        it "Subnet public-subnet Should Exist" {
            $subnet = Get-AzVirtualNetworkSubnetConfig -Name "public-subnet" -VirtualNetwork $vNet -ErrorAction SilentlyContinue
            $subnet| Should Not be $null
        }
        
        it "Subnet public-subnet Should have Address Range 10.0.2.0/23" {
            $subnet = Get-AzVirtualNetworkSubnetConfig -Name "public-subnet" -VirtualNetwork $vNet -ErrorAction SilentlyContinue
            $subnet.AddressPrefix | Should be "10.0.2.0/23"
        }
         
    }
}


Describe "Virtual Machine Tests" -tag "AzureInfrastructure"{
    context "VM Tests"{
        $vmName="$prefix-Vm1"
        $vm= Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup
    
        it "Virtual Machine $vmName Should Exist" {
            $vm| Should Not be $null
        }

        it "Virtual Machine $vmName Should Be Size Standard_DS1_v2" {
            $vm.HardwareProfile.VmSize | should be "Standard_DS1_v2"
        }

        it "Virtual Machine $vmName Should Be Located in West Europe" {
            $vm.Location | should be "westeurope"
        }

    }
           
}
