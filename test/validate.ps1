Param(
    [Parameter(Mandatory = $false)][string]$templateLibraryName = (Split-Path (Resolve-Path "$PSScriptRoot\..") -Leaf),
    [string]$Location = "canadacentral",
    [string]$subscription = "",
    [switch]$devopsCICD = $false,
    [switch]$doNotCleanup = $false
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

function getValidationURL {
    $remoteURL = git config --get remote.origin.url
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $remoteURLnogit = $remoteURL -replace '\.git', ''
    $remoteURLRAW = $remoteURLnogit -replace 'github.com', 'raw.githubusercontent.com'
    $validateURL = $remoteURLRAW + '/' + $currentBranch + '/template/azuredeploy.json'
    return $validateURL
}

function getBaseParametersURL {
    $remoteURL = git config --get remote.origin.url
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $remoteURLnogit = $remoteURL -replace '\.git', ''
    $remoteURLRAW = $remoteURLnogit -replace 'github.com', 'raw.githubusercontent.com'
    $baseParametersURL = $remoteURLRAW + '/' + $currentBranch + '/test/parameters/'
    return $baseParametersURL
}

$currentBranch = "dev"
$validationURL = "https://raw.githubusercontent.com/canada-ca-azure-templates/$templateLibraryName/dev/template/azuredeploy.json"
$baseParametersURL = "https://raw.githubusercontent.com/canada-ca-azure-templates/$templateLibraryName/dev/test/"

if (-not $devopsCICD) {
    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($currentBranch -eq 'master') {
        $confirmation = Read-Host "You are working off the master branch... are you sure you want to validate the template from here? Switch to the dev branch is recommended. Continue? (y/n)"
        if ($confirmation -ne 'y') {
            exit
        }
    }

    $validationURL = getValidationURL
    $baseParametersURL = getBaseParametersURL

    # Make sure we update code to git
    # git branch dev ; git checkout dev ; git pull origin dev
    git add ..\. ; git commit -m "Update validation" ; git push origin $currentBranch
}

if ($subscription -ne "") {
    Select-AzContext -Subscription $subscription
}

# Cleanup validation resource content in case it did not properly completed and left over components are still lingeringcd
if (-not $doNotCleanup) {
    Write-Host "Cleanup old $templateLibraryName validation resources if needed...";

    New-AzResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\parameters\cleanup.json") -Force -Verbose
}

# Start the deployment
Write-Host "Starting $templateLibraryName dependancies deployment...";

New-AzDeployment -Location $Location -Name "Deploy-Infrastructure-Dependancies" -TemplateUri "https://raw.githubusercontent.com/canada-ca-azure-templates/masterdeploy/20190514/template/masterdeploysub.json" -TemplateParameterFile (Resolve-Path -Path "$PSScriptRoot\parameters\masterdeploysub.parameters.json") -baseParametersURL $baseParametersURL -Verbose;

$provisionningState = (Get-AzureRmDeployment -Name "Deploy-Infrastructure-Dependancies").ProvisioningState

if ($provisionningState -eq "Failed") {
    Write-Host "One of the jobs was not successfully created... exiting..."
    exit
}

# Validating server template
Write-Host "Starting $templateLibraryName validation deployment...";

New-AzResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Name "validate-$templateLibraryName-template" -TemplateUri $validationURL -TemplateParameterFile (Resolve-Path "$PSScriptRoot\parameters\validate.parameters.json") -Verbose

$provisionningState = (Get-AzResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Name "validate-$templateLibraryName-template").ProvisioningState

if ($provisionningState -eq "Failed") {
    Write-Host  "Test deployment failed..."
}

# Cleanup validation resource content
if (-not $doNotCleanup) {
    Write-Host "Cleanup old $templateLibraryName validation resources...";

    New-AzResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\parameters\cleanup.json") -Force -Verbose
}