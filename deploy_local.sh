#!/bin/bash

# Load variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please create one with NREL_API_KEY, USER_EMAIL, and EIA_API_KEY."
    exit 1
fi

# Create a temporary directory for the local site
mkdir -p ./local_test_site

# Function to build the local site
build_site() {
    echo "[Build] Injecting secrets and preparing index.html..."
    sed "s|NREL_API_KEY_PLACEHOLDER|$NREL_API_KEY|g; s|USER_EMAIL_PLACEHOLDER|$USER_EMAIL|g; s|EIA_API_KEY_PLACEHOLDER|$EIA_API_KEY|g" energy_efficiency.html > ./local_test_site/index.html
    echo "[Build] Done. Last build: $(date +%H:%M:%S)"
}

# Initial build
build_site

echo "--------------------------------------------------------"
echo "Starting local server on port 8080..."
echo "Visit: http://localhost:8080"
echo "--------------------------------------------------------"

# Start the server in the background
python3 -m http.server 8080 --directory ./local_test_site &
SERVER_PID=$!

# Trap Ctrl+C to kill the server
trap "kill $SERVER_PID; echo -e '\nStopping server...'; exit" INT

echo "[Watch] Monitoring energy_efficiency.html for changes..."
echo "Press ENTER to rebuild and update the server, or Ctrl+C to stop."

while true; do
    # Check for file modification
    if [[ energy_efficiency.html -nt ./local_test_site/index.html ]]; then
        echo -e "\n[!] Change detected in energy_efficiency.html"
        read -p "Hit ENTER to rebuild: "
        build_site
        echo "Ready. Refresh your browser."
    fi
    sleep 2
done
