#!/bin/bash

# Define variables
TRIVY_VERSION="0.51.1"  # Change this to the desired Trivy version
TRIVY_DIR=".tools"

install_trivy(){
# Create tools directory if it doesn't exist
mkdir -p $TRIVY_DIR
# Download Trivy
echo "Downloading Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $TRIVY_DIR v$TRIVY_VERSION

# Make Trivy executable
chmod +x $TRIVY_DIR/trivy
}


run_audit(){

if command $TRIVY_DIR/trivy -v &> /dev/null; then
        INSTALLED_VERSION=$($TRIVY_DIR/trivy -v | grep -oP '^Version:\s\K(\d+\.\d+\.\d+)')
        echo "$INSTALLED_VERSION"
        if [ "$INSTALLED_VERSION" == "$TRIVY_VERSION" ]; then
            echo "Trivy version $EXPECTED_VERSION is installed."
        else
            echo "Installed Trivy version ($INSTALLED_VERSION) does not match the expected version ($EXPECTED_VERSION)."
            install_trivy
        fi
else
    echo "Trivy is not installed."
    install_trivy
fi

# Run Trivy to check for vulnerabilities higher than "MEDIUM"
echo "Running Trivy..."
$TRIVY_DIR/trivy fs . --severity MEDIUM,HIGH,CRITICAL --no-progress

echo "Done."

echo "Run npm audit"
npm audit
echo "Done."
}

# Display help message
show_help() {
    echo "Usage: do [command]"
    echo ""
    echo "Commands:"
    echo "  run_trivy        Download and set up Trivy and run Trivy scan for vulnerabilities higher than MEDIUM"
    echo "  help             Show this help message"
}

# Main script logic
case "$1" in
    run_audit)
        run_audit
        ;;
    help|*)
        show_help
        ;;
esac
