#!/bin/bash

# Load variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please create one with NREL_API_KEY and USER_EMAIL."
    exit 1
fi

# Create a temporary directory for the local site
mkdir -p ./local_test_site

# Inject secrets and save as index.html in the temporary directory
sed "s/NREL_API_KEY_PLACEHOLDER/$NREL_API_KEY/g; s/USER_EMAIL_PLACEHOLDER/$USER_EMAIL/g" energy_efficiency.html > ./local_test_site/index.html

echo "Starting local server on port 8080..."
echo "Visit: http://localhost:8080"
echo "Press Ctrl+C to stop the server."

# Serve the temporary directory
python3 -m http.server 8080 --directory ./local_test_site
