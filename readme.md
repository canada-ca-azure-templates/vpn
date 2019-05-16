# Template Name

## Introduction

This template will create an Active Directory forest with 1 or 2 domains, each with 1 or 2 DCs.

The template creates the following: 

* The root domain is always created; the child domain is optional.
* Choose to have one or two DCs per domain.
* Choose names for the Domains, DCs, and network objects.  
* Choose the VM type from a prepopulated list.
* Use either Windows Server 2012, Windows Server 2012 R2, or Windows Server 2016.

A forest with two domains in Azure is especially useful for AD-related
development, testing, and troubleshooting. Many enterprises have complex
Active Directories with multiple domains, so if you are developing an
application for such companies it makes a lot of sense to use a
multi-domain Active Directory as well.

The Domain Controllers are placed in an Availability Set to maximize uptime. Each domain has its own Availability set.

The VMs are provisioned with managed disks.  Each VM will have the AD-related management tools installed.

## Security Controls

The following security controls can be met through configuration of this template:

* Unknown.

## Dependancies

The following items are assumed to exist already in the deployment:

* [Resource Group](<https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/resourcegroups/latest/readme.md>)
* [Virtal Network](<https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/vnet-subnet/latest/readme.md>)
* [KeyVault](<https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/keyvaults/latest/readme.md>)

## Parameter format

```JSON
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "keyVaultResourceGroupName": {
      "value": "Demo-Keyvault-RG"
    },
    "keyVaultName": {
       "value": "Demo-Keyvault-MGMT"
    },
    "DomainName": {
      "value": "demo.gc.ca.local"
    },
    "createChildDomain": {
      "value": false
    },
    "ChildDomainName": {
      "value": "mgmt"
    },
    "VMSize": {
      "value": "Standard_B2ms"
    },
    "vnetRG": {
      "value": "Demo-NetMGMT-RG"
    },
    "vnetName": {
      "value": "Demo-NetMGMT-VNET"
    },
    "vnetAddressRange": {
      "value": "10.10.0.0/20"
    },
    "adSubnetName": {
      "value": "APP"
    },
    "adSubnet": {
      "value": "10.10.1.0/24"
    },
    "RootDC1Name": {
      "value": "Demo-RootDC01"
    },
    "RootDC1IPAddress": {
      "value": "10.10.1.8"
    },
    "RootDC2Name": {
      "value": "demo-RootDC02"
    },
    "RootDC2IPAddress": {
      "value": "10.10.1.9"
    },
    "ChildDC3Name": {
      "value": "Demo-MgmtDC01"
    },
    "ChildDC3IPAddress": {
      "value": "10.10.1.10"
    },
    "ChildDC4Name": {
      "value": "Demo-MgmtDC02"
    },
    "ChildDC4IPAddress": {
      "value": "10.10.1.11"
    },
    "tagValues": {
      "value": {
          "workload": "Domain Controller",
          "owner": "demo.user@demo.gc.ca",
          "businessUnit": "DEMO-CCC",
          "costCenterOwner": "DEMO-CCC",
          "environment": "Sandbox",
          "classification": "Unclassified",
          "version": "0.4"
      },
      "ReverseZoneObject": {
        "value":["2.10.10", "1.10.10"]
      }
    }
  }
}
```

## Parameter Values

### Main Template

| Name                      | Type   | Required | Value                                                                                                                                            |
| ------------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| containerSasToken         | string | No       | A SaS token for the private blob storage                                                                                                         |
| keyVaultResourceGroupName | string | Yes      | Name of the existing resource group for the keyvault                                                                                             |
| keyVaultName              | string | Yes      | Name of the existing keyvault                                                                                                                    |
| DomainName                | string | Yes      | Full qualified domain name for the forest root domain                                                                                            |
| createChildDomain         | bool   | No       | Indicates whether or not to create the child domain.  Default is false                                                                           |
| ChildDomainName           | string | No       | Full qualified domain name for the child domain                                                                                                  |
| VMSize                    | enum   | Yes      | Size for the VM's.   See available [VM Sizes](<https://docs.microsoft.com/rest/api/compute/virtualmachines/listavailablesizes>) for more details |
| vnetRG                    | string | Yes      | Name of the resource group for the virtual network that will be used by the VMs.                                                                 |
| vnetName                  | string | Yes      | name of the virstual network that will be used by the VMs.                                                                                       |
| vnetAddressRange          | string | Yes      | The virtual networks address range                                                                                                               |
| adSubnetName              | string | Yes      | The name of the subnet in which to place the active directory servers                                                                            |
| adSubnet                  | string | Yes      | The address space for the ad subnet                                                                                                              |
| RootDC1Name               | string | Yes      | The name of the root domain controller                                                                                                           |
| RootDC1IPAddress          | string | Yes      | The IP address to use for the root domain controller                                                                                             |
| RootDC2Name               | string | Yes      | The secondary root domain controller name                                                                                                        |
| ChildDC3Name              | string | No       | The child domain controller name                                                                                                                 |
| ChildDC3IPAddress         | string | No       | The child domain controller IP address                                                                                                           |
| ChildDC4Name              | string | No       | The secondary child domain controller name                                                                                                       |
| ChildDC4IPAddress         | string | No       | The secondary child domain controller IP address                                                                                                 |
| ReverseZoneObject         | array  | No       | String array of reverse zone objects to create                                                                                                   |
| tagValues                 | object | No       | The tags to set for the deployment.  - [tagValues object](###tagvalues-object)                                                                   |

### tagValues object

| Name     | Type   | Required | Value      |
| -------- | ------ | -------- | ---------- |
| tagname1 | string | No       | tag1 value |
| ...      | ...    | ...      | ...        |
| tagnameX | string | No       | tagX value |

### Credits

This project was initially copied from the
[active-directory-new-domain-ha-2-dc](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc)
project by Simon Davies, part of the the Azure Quickstart templates.

## History

| Date     | Release                                                                                 | Change                                                                                                    |
| -------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 20181031 |                                                                                         | Removed network creation                                                                                  |
|          |                                                                                         | Moved username and password to keyvault                                                                   |
|          |                                                                                         | Removed network dependencies from NSG, VMs                                                                |
|          |                                                                                         | Changed container sasToken parameter                                                                      |
|          |                                                                                         | Set artifact location default as: deployment().properties.templateLink.uri                                |
|          |                                                                                         | Combined firstVMTemplateUri and nextVMTemplateUri as they call the same file                              |
|          |                                                                                         | Added vnet information to parameters                                                                      |
|          |                                                                                         | Added new DS_v3 sizes and removed lower one core ones.                                                    |
|          |                                                                                         | Added "Microsoft.Resources/deployments/CreateForest" dependency to Childdomain as it would sometimes fail |
|          |                                                                                         | Removed updateDNS for now as it needs to be modified                                                      |
|          |                                                                                         | Added in common tag structure                                                                             |
|          |                                                                                         | Added timezone to default to EST                                                                          |
|          |                                                                                         | Added Forward Zones as an optional parameter                                                              |
| 20190508 |                                                                                         | Updated documentation                                                                                     |
| 20190516 | [20190516](https://github.com/canada-ca-azure-templates/active-directory/tree/20190516) | Rename base template to active-directory.json. Created test validation.                                   |
