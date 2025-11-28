param(
    [Parameter(Mandatory = $true)] [string] $DeploymentResourceGroupName,
    [Parameter(Mandatory = $true)] [string] $DeploymentStorageAccountName,
    [Parameter(Mandatory = $true)] [string] $WorkSpace,
    [Parameter(Mandatory = $true)] [bool]   $ContinueEvenIfResourcesAreGettingDestroyed
)

$ErrorActionPreference = "Stop"
Write-Host "3 Current Directory: $(Get-Location)"
#-----------------------------------------
# Helper Functions
#-----------------------------------------

function Log {
    param([string]$Message)
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message"
}

#-----------------------------------------
# SCRIPT START
#-----------------------------------------

cd $env:BUILD_SOURCESDIRECTORY/Deployment/src

Write-Host "Current Directory: $(Get-Location)"
Write-Host "Script Arguments:"
Write-Host "  DeploymentResourceGroupName: $DeploymentResourceGroupName"
Write-Host "  DeploymentStorageAccountName: $DeploymentStorageAccountName"
Write-Host "  WorkSpace: $WorkSpace"
Write-Host "  ContinueEvenIfResourcesAreGettingDestroyed: $ContinueEvenIfResourcesAreGettingDestroyed"

Log "Starting Terraform deployment for environment: $WorkSpace"

#-----------------------------------------
# Terraform Init
#-----------------------------------------
Log "Initializing Terraform backend..."

$initArgs = @(
    "init",
    "-backend-config=resource_group_name=$DeploymentResourceGroupName",
    "-backend-config=storage_account_name=$DeploymentStorageAccountName",
    "-backend-config=key=terraform.deployment.tfplan"
)
Log "Direct call: terraform $($initArgs -join ' ')"
terraform $initArgs
if ($LASTEXITCODE -ne 0) {
    throw "Terraform command failed: terraform $($initArgs -join ' ')"
}

Write-Host "4 Current Directory: $(Get-Location)"
#-----------------------------------------
# Workspace Handling
#-----------------------------------------
Log "Checking/Creating workspace: $WorkSpace"

try {
    terraform workspace new $WorkSpace *>$null
} catch {
    # Ignore if exists
}

$wsArgs = @("workspace", "select", $WorkSpace)
Log "Direct call: terraform $($wsArgs -join ' ')"
terraform $wsArgs
if ($LASTEXITCODE -ne 0) {
    throw "Terraform command failed: terraform $($wsArgs -join ' ')"
}

#-----------------------------------------
# Validation
#-----------------------------------------
Log "Validating Terraform configuration..."
$validateArgs = @("validate")
Log "Direct call: terraform $($validateArgs -join ' ')"
terraform $validateArgs
if ($LASTEXITCODE -ne 0) {
    throw "Terraform command failed: terraform $($validateArgs -join ' ')"
}

#-----------------------------------------
# Plan
#-----------------------------------------
Log "Running Terraform plan..."
Write-Host "5 Current Directory: $(Get-Location)"
terraform plan -out "terraform.deployment.tfplan" `
    | Tee-Object -FilePath terraform_output.txt

if ($LASTEXITCODE -ne 0) {
    throw "Terraform plan failed"
}

#-----------------------------------------
# Detect Destructive Changes
#-----------------------------------------
$destroyCount = (
    Select-String -Path terraform_output.txt -Pattern "destroy" |
    Where-Object { $_ -ne "" }
).Length

if ($destroyCount -ge 2) {
    Log "WARNING: Terraform is planning to DESTROY resources! Count = $destroyCount"

    if (-not $ContinueEvenIfResourcesAreGettingDestroyed) {
        Log "Stopping execution due to destructive changes. Enable continue flag to override."
        exit 1
    }

    Log "Destructive plan detected but continuing because continue flag = TRUE"
}

#-----------------------------------------
# Apply (Disabled for Safety)
#-----------------------------------------
# Log "Applying Terraform plan..."
# $applyArgs = @("apply", "-auto-approve", "terraform.deployment.tfplan")
# Log "Direct call: terraform $($applyArgs -join ' ')"
# terraform $applyArgs
# if ($LASTEXITCODE -ne 0) {
#     throw "Terraform command failed: terraform $($applyArgs -join ' ')"
# }

#-----------------------------------------
# Output Variables
#-----------------------------------------
Log "Extracting Terraform outputs..."

$tfOutput = terraform output -json | ConvertFrom-Json

$webappUrl = $tfOutput.webapp_url.value
$webappName = $tfOutput.webapp_name.value

Log "Web App Name: $webappName"
Log "Web App URL:  $webappUrl"

Write-Host "##vso[task.setvariable variable=webapp_url;isOutput=true]$webappUrl"
Write-Host "##vso[task.setvariable variable=webapp_name;isOutput=true]$webappName"

Log "Terraform deployment completed successfully."
