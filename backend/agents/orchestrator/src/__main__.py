"""Entry point for running the orchestrator agent as a module."""
import os
from agent import app

if __name__ == "__main__":
    # Configure the app to run on 0.0.0.0:8000 to allow external connections
    # This is required for Kubernetes probes to work correctly
    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 8000))
    app.run(host=host, port=port)
