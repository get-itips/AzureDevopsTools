#Export-TFSReleaseDefinition.ps1
#Todo: Make it to run on other TFS versions than 2017
#Author: Andres Gorzelany
#Github handle: get-itips
#Source documentation
#https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.0
#https://docs.microsoft.com/en-us/azure/devops/integrate/previous-apis/overview?view=azure-devops-2019&viewFallbackFrom=vsts
#https://docs.microsoft.com/en-us/azure/devops/integrate/previous-apis/tfs/projects?view=azure-devops-2019

param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$CsvPath="",

    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Fqdn="",

    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$CollectionName=""
)
#$csvpath= "output.csv"
#$fqdn="tfs"
#$collectionName="collection"

Write-Host "###########################" -ForegroundColor Blue
Write-Host "Export-TFSReleaseDefinition.ps1 version 0.2" -ForegroundColor White
Write-Host "Runtime values set by user:" -ForegroundColor White
Write-Host "###########################" -ForegroundColor Blue
Write-Host "CSV will be saved to " $CsvPath -ForegroundColor Blue
$tfsUrl="http://$fqdn/$collectionName"
Write-Host "TFS Url will be " $tfsUrl -ForegroundColor Blue
read-host

$credential=Get-Credential
$csv = "Project;ReleaseDefinition`r`n"

$WebSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession -Property @{Credentials=($credential)}

$uriProjects="$tfsUrl/_apis/projects?api-version=1.0"

$responseProjects=Invoke-RestMethod -WebSession $websession -Method GET -Uri $uriProjects

foreach($project in $responseProjects.value.name)
{

$uri= "http://$fqdn/$collectionName/"+$project+"/_apis/release/definitions?api-version=2.2-preview.1"

$response=Invoke-RestMethod -WebSession $websession -Method GET -Uri $uri

$withoutRelDef=$true
foreach($r in $response.value.name)
{
	
	     $csv+=$project+";"+$r
            $csv +="`r`n"
$withoutRelDef=$false
}

if($withoutRelDef)
{
	     $csv+=$project+";NULL"
            $csv +="`r`n"
}
}
$csv
$csv | Set-Content -Path $csvpath -Encoding utf8
write-host "CSV File Saved to..." $csvpath
