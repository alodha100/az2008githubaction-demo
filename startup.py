# Startup configuration for Azure Web Apps
import os
from app import app

if __name__ == "__main__":
    # Azure Web Apps will set the PORT environment variable
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=False, host='0.0.0.0', port=port)
