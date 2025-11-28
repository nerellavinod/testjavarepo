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

# Corrected Terraform wrapper (string[] array)
function Run-Terraform {
    param([string[]]$Args)

    Log "Running: terraform $Args"
    terraform @Args

    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed: terraform $Args"
    }
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

Run-Terraform @(
    "init",
    "-backend-config=resource_group_name=$DeploymentResourceGroupName",
    "-backend-config=storage_account_name=$DeploymentStorageAccountName",
    "-backend-config=key=terraform.deployment.tfplan"
)
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

Run-Terraform @("workspace", "select", $WorkSpace)

#-----------------------------------------
# Validation
#-----------------------------------------
Log "Validating Terraform configuration..."
Run-Terraform @("validate")

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
# Run-Terraform @("apply", "-auto-approve", "terraform.deployment.tfplan")

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
