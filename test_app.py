import unittest
from app import app

class FlaskAppTestCase(unittest.TestCase):
    def setUp(self):
        """Set up test client"""
        self.app = app.test_client()
        self.app.testing = True

    def test_home_route(self):
        """Test the home page"""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Python Web App', response.data)

    def test_health_check(self):
        """Test health check endpoint"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        
        # Parse JSON response
        import json
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
        self.assertIn('message', data)

    def test_app_info(self):
        """Test app info endpoint"""
        response = self.app.get('/api/info')
        self.assertEqual(response.status_code, 200)
        
        # Parse JSON response
        import json
        data = json.loads(response.data)
        self.assertEqual(data['app'], 'Python Flask Web App')
        self.assertEqual(data['version'], '1.0.0')

if __name__ == '__main__':
    unittest.main()
