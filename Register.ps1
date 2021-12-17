#Connect-AzAccount

Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview


Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages |
    Where-Object RegistrationState -ne Registered | 
    Register-AzResourceProvider