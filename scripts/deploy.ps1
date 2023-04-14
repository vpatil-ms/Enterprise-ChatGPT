$output = azd env get-values

foreach ($line in $output) {
    $name = $line.Split('=')[0]
    $value = $line.Split('=')[1].Trim('"')
    Set-Item -Path "env:\$name" -Value $value
}

Write-Host "Environment variables set."

az account set --subscription $env:AZURE_SUBSCRIPTION_ID

cd ./app/frontend
$SWA_DEPLOYMENT_TOKEN = az staticwebapp secrets list --name $env:AZURE_STATICWEBSITE_NAME --query "properties.apiKey" --output tsv
swa deploy --env production --deployment-token $SWA_DEPLOYMENT_TOKEN

cd ../backend
$AZURE_SEARCH_KEY = az cognitiveservices account keys list --name $env:AZURE_SEARCH_SERVICE --resource-group $env:AZURE_RESOURCE_GROUP --query "key1" --output tsv
az functionapp config appsettings list --name $env:AZURE_FUNCTION_NAME --resource-group $env:AZURE_RESOURCE_GROUP --settings AZURE_SEARCH_KEY=$AZURE_SEARCH_KEY
func azure functionapp publish $env:AZURE_FUNCTION_NAME