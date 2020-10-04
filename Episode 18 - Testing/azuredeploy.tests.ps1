#Requires -Modules Pester
<#
.SYNOPSIS
    Tests a specific ARM template
.EXAMPLE
    Invoke-Pester 
.NOTES
    This file has been created as an example of using Pester to evaluate ARM templates

#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Split-Path -Leaf $here

$TempValidationRG = "Pester-Validation-RG"
$location = "West Europe"





Describe "Template: $template" -Tags Unit {
     BeforeAll {
         New-AzResourceGroup -Name $TempValidationRG -Location $Location
    }

    
    Context "Template Syntax" {
        
        It "Has a JSON template" {        
            "$here\azuredeploy.json" | Should Exist
        }
        
        It "Has a parameters file" {        
            "$here\azuredeploy.parameters.json" | Should Exist
        }
        
        It "Has a metadata file" {        
            "$here\metadata.json" | Should Exist
        }

        It "Converts from JSON" {
            $templateProperties = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue)
            $templateProperties | Should not be $null
        }

        It "Has the expected properties" {
            $expectedProperties = '$schema',
            'contentVersion',
            'parameters',
            'variables',
            'resources',                                
            'outputs' | Sort-Object
            $templateProperties = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue) | Get-Member -MemberType NoteProperty | % Name | sort-object
            $templateProperties | Should Be $expectedProperties
        }
        
        It "Creates the expected Azure resources" {
            $expectedResources = 'Microsoft.Storage/storageAccounts',
            'Microsoft.Automation/automationAccounts',
            'Microsoft.Network/virtualNetworks',
            'Microsoft.Network/publicIPAddresses',
            'Microsoft.Compute/virtualMachineScaleSets',
            'Microsoft.Insights/autoscaleSettings',
            'Microsoft.Storage/storageAccounts',
            'Microsoft.Network/loadBalancers' | sort-object
            $templateResources = (get-content "$here\azuredeploy.json" | ConvertFrom-Json -ErrorAction SilentlyContinue).Resources.type | sort-object
            $templateResources | Should Be $expectedResources
        }
        


    }
    
    Context "Template Validation" {
          
        It "Template $here\azuredeploy.json and parameter file  passes validation" {
      
            # Complete mode - will deploy everything in the template from scratch. If the resource group already contains things (or even items that are not in the template) they will be deleted first.
            # If it passes validation no output is returned, hence we test for NullOrEmpty
            $ValidationResult = Test-AzResourceGroupDeployment -ResourceGroupName $TempValidationRG -Mode Complete -TemplateFile "$here\azuredeploy.json" -TemplateParameterFile "$here\azuredeploy.parameters.json"
            $ValidationResult | Should BeNullOrEmpty
        }
    }

     AfterAll {
         Remove-AzResourceGroup $TempValidationRG -Force
     }
}
