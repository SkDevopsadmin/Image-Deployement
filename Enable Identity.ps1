$imageResourceGroup='<Resource Group>'
$location='<location>'
$subscriptionID=(Get-AzContext).Subscription.Id

#'Az.ImageBuilder','Az.ManagedServiceIdentity' | ForEach-Object ( Install-Module -Name $_.AllowPrerelease )

Install-Module -Name Az.ImageBuilder
Install-Module -Name Az.ManagedServiceIdentity


[int]$timeInt=$(get-date -UFormat '%s')
$imageRoleDefName="Azure Image Builder Image Def $timeInt"
$identityName="<Managed Identity Name>"

New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName
#/subscriptions/<subscription id>/resourcegroups/<resi=ource group name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<managed identity name>


$identityNamePrincipalId=(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId


$myRoleImageCreationUrl="https://github.com/SkDevopsadmin/Image-Deployement/blob/main/Roleimagecreation.json"
$myRoleImageCreationPath="myRoleImageCreation.json"

Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

$content=Get-Content -Path $myRoleImageCreationPath 
$content=$content -replace  '<subscriptionID>',$subscriptionID
$content=$content -replace  '<rgName>',$imageResourceGroup
$content=$content -replace  'Azure Image Builder Service Image Creation Role',$imageRoleDefName
$content | Out-File -FilePath $myRoleImageCreationPath -Force

New-AzRoleDefinition -InputFile $myRoleImageCreationPath

$RoleAssignParams=@{
    ObjectId=$identityNamePrincipalId
    RoleDefinitionName=$imageRoleDefName
    Scope="/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams

Get-AzRoleAssignment -ObjectId $identityNamePrincipalId  | Select-Object DisplayName,RoleDeifinitionName

