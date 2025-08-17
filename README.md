# Python Flask Web App for Azure Deployment

A simple Python Flask web application configured for deployment to Azure Web Apps using GitHub Actions CI/CD pipeline.

## 🚀 Features

- **Flask Web Framework**: Lightweight and flexible Python web framework
- **Health Check Endpoints**: Built-in monitoring endpoints for application health
- **Azure Web Apps Ready**: Optimized for Azure Web Apps deployment
- **GitHub Actions CI/CD**: Automated build and deployment pipeline
- **Production Ready**: Includes Gunicorn WSGI server for production

## 📁 Project Structure

```
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── templates/
│   └── index.html        # Homepage template
├── .github/
│   └── workflows/
│       └── main_webapp.yml # GitHub Actions workflow
└── README.md             # This file
```

## 🛠️ Local Development

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd <your-repo-name>
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   python app.py
   ```

5. **Access the application**
   - Open your browser and go to `http://localhost:5000`
   - Health check: `http://localhost:5000/api/health`
   - App info: `http://localhost:5000/api/info`

## ☁️ Azure Deployment Setup

### Step 1: Create Azure Web App

1. **Using Azure CLI:**
   ```bash
   # Login to Azure
   az login
   
   # Create resource group
   az group create --name myResourceGroup --location "East US"
   
   # Create App Service plan
   az appservice plan create --name myAppServicePlan --resource-group myResourceGroup --sku B1 --is-linux
   
   # Create Web App
   az webapp create --resource-group myResourceGroup --plan myAppServicePlan --name YOUR_UNIQUE_APP_NAME --runtime "PYTHON|3.11" --deployment-local-git
   ```

2. **Using Azure Portal:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Click "Create a resource" → "Web App"
   - Fill in the details:
     - **Name**: Choose a unique name
     - **Runtime stack**: Python 3.11
     - **Operating System**: Linux
   - Click "Create"

### Step 2: Configure GitHub Actions

1. **Get Publish Profile:**
   - In Azure Portal, go to your Web App
   - Click "Get publish profile" and download the file
   - Copy the entire contents of this file

2. **Set GitHub Secrets:**
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `AZUREAPPSERVICE_PUBLISHPROFILE`
   - Value: Paste the publish profile content
   - Click "Add secret"

3. **Update Workflow File:**
   - Open `.github/workflows/main_webapp.yml`
   - Replace `YOUR_AZURE_WEB_APP_NAME` with your actual Azure Web App name

### Step 3: Deploy

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Initial commit with Flask app and GitHub Actions"
   git push origin main
   ```

2. **Monitor Deployment:**
   - Go to your GitHub repository → Actions tab
   - Watch the workflow execution
   - Once complete, your app will be live at `https://YOUR_APP_NAME.azurewebsites.net`

## 🔧 Configuration

### Environment Variables

The application supports the following environment variables:

- `PORT`: Port number (default: 5000)
- `FLASK_ENV`: Environment mode (development/production)

### Azure Web App Configuration

Set these in Azure Portal under Configuration → Application Settings:

- `SCM_DO_BUILD_DURING_DEPLOYMENT`: `true`
- `PYTHON_VERSION`: `3.11`

## 🧪 API Endpoints

- `GET /`: Homepage with application information
- `GET /api/health`: Health check endpoint
- `GET /api/info`: Application information and version

## 🔒 Security Considerations

- The app uses Flask's built-in security features
- Environment variables should be used for sensitive configuration
- Consider implementing authentication for production use
- Enable HTTPS in Azure Web Apps settings

## 📊 Monitoring

- Use the `/api/health` endpoint for health monitoring
- Azure Web Apps provides built-in monitoring and logging
- Check logs in Azure Portal under Monitoring → Log stream

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Troubleshooting

### Common Issues:

1. **Build fails**: Check Python version compatibility in workflow
2. **Deployment fails**: Verify publish profile secret is correctly set
3. **App doesn't start**: Check application logs in Azure Portal
4. **Port issues**: Ensure the app listens on the correct port (from environment variable)

### Getting Help:

- Check Azure Web Apps documentation
- Review GitHub Actions logs for detailed error messages
- Use Azure Portal's diagnostic tools

---

**Happy Coding!** 🎉
