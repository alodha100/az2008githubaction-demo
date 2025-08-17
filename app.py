from flask import Flask, render_template, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    """Home page route"""
    return render_template('index.html', title='Python Web App')

@app.route('/api/health')
def health_check():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'message': 'Application is running successfully',
        'version': '1.0.0'
    })

@app.route('/api/info')
def app_info():
    """Application information endpoint"""
    return jsonify({
        'app': 'Python Flask Web App',
        'version': '1.0.0',
        'environment': os.environ.get('FLASK_ENV', 'production'),
        'python_version': os.sys.version
    })

if __name__ == '__main__':
    # For development
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
