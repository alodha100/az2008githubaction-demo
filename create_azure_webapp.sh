#!/bin/bash
# Azure Web App Creation Script for Flask Application
# Run this script in Azure Cloud Shell

echo "🚀 Starting Azure Web App creation for Flask application..."
echo "================================================="

# Set variables
RESOURCE_GROUP="rg-az2008-demo"
LOCATION="westus2"  # Changed to West US 2 for quota availability
APP_SERVICE_PLAN="plan-az2008-demo"
WEB_APP_NAME="az2008-demo-webapp-$(date +%s)"  # Adds timestamp for global uniqueness

echo "📋 Configuration:"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "App Service Plan: $APP_SERVICE_PLAN"
echo "Web App Name: $WEB_APP_NAME"
echo ""

# Step 1: Create Resource Group
echo "🏗️  Step 1: Creating Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output table

if [ $? -eq 0 ]; then
    echo "✅ Resource Group created successfully"
else
    echo "❌ Failed to create Resource Group"
    exit 1
fi

# Step 2: Create App Service Plan
echo ""
echo "🏗️  Step 2: Creating App Service Plan..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku B1 \
  --location $LOCATION \
  --output table

if [ $? -eq 0 ]; then
    echo "✅ App Service Plan created successfully"
else
    echo "❌ Failed to create App Service Plan"
    exit 1
fi

# Step 3: Create Web App
echo ""
echo "🏗️  Step 3: Creating Web App..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $WEB_APP_NAME \
  --runtime "PYTHON:3.11" \
  --startup-file "startup.py" \
  --output table

if [ $? -eq 0 ]; then
    echo "✅ Web App created successfully"
else
    echo "❌ Failed to create Web App"
    exit 1
fi

# Step 4: Configure App Settings
echo ""
echo "🏗️  Step 4: Configuring App Settings..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --settings \
    PORT=5000 \
    FLASK_ENV=production \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    PYTHON_VERSION=3.11 \
  --output table

if [ $? -eq 0 ]; then
    echo "✅ App Settings configured successfully"
else
    echo "❌ Failed to configure App Settings"
    exit 1
fi

# Step 5: Enable logging
echo ""
echo "🏗️  Step 5: Enabling Application Logging..."
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --application-logging true \
  --level information \
  --output table

# Step 6: Display Results
echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo "✅ Resource Group: $RESOURCE_GROUP"
echo "✅ Web App Name: $WEB_APP_NAME"
echo "✅ Web App URL: https://$WEB_APP_NAME.azurewebsites.net"
echo ""

# Step 7: Get Publish Profile
echo "📄 Getting Publish Profile for GitHub Actions..."
echo "================================================"
echo "Copy the XML content below and save it as 'AZUREAPPSERVICE_PUBLISHPROFILE' secret in GitHub:"
echo ""

az webapp deployment list-publishing-profiles \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --xml

echo ""
echo "📋 GitHub Secrets to Add:"
echo "========================"
echo "1. Secret Name: AZURE_WEBAPP_NAME"
echo "   Secret Value: $WEB_APP_NAME"
echo ""
echo "2. Secret Name: AZUREAPPSERVICE_PUBLISHPROFILE"
echo "   Secret Value: [Copy the XML content above]"
echo ""
echo "🔗 Add secrets at: https://github.com/alodha100/az2008githubaction-demo/settings/secrets/actions"
echo ""
echo "🚀 Your Flask app will be available at: https://$WEB_APP_NAME.azurewebsites.net"
