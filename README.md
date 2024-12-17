# azure-ml-secure-blueprint
This is a blueprint to provide a basis for the secure usage of the Azure Machine Learning Workspace.

# Prerequisites

- Recent version of Azure CLI (tested with 2.62.0)
- Azure Resource Group / Subscription

# Parameters
For the deployment, I've used a parameter file. It's named `app-parameters.json` and contains the following:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "instance": {
            "value": "dev"
        },
        "prefix": {
            "value": "blueprint"
        },
        "location": {
            "value": "westeurope"
        }
    }
}
```

Feel free to create mutliple Parameter files for different environments or locations.

# Deployment
To deploy the blueprint, you can use the following command:

```pwsh
az deployment group create --resource-group <resource-group> --template-file ./infrastructure/app-infrastructure.bicep --parameters @app-parameters.json --parameters "vmAdminPassword=<yourPassword>"
```

The Password is used to access the VM. The username is set to `developer`.