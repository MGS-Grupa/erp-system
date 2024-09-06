#!/bin/bash

# Define an array of modules
modules=("projekti" "kvaliteta" "prodaja")

# Loop through each module
for module in "${modules[@]}"; do
    echo "Updating $module..."

    # Change directory to the module
    cd /opt/erp_system/$module

    # Update requirements.txt
    if ! grep -q "gunicorn" requirements.txt; then
        echo "Adding gunicorn to requirements.txt in $module"
        echo "gunicorn==20.1.0" >> requirements.txt
    else
        echo "gunicorn already present in requirements.txt in $module"
    fi

    # Update Dockerfile
    if grep -q "CMD" Dockerfile; then
        echo "Updating CMD in Dockerfile for $module"
        sed -i 's|CMD .*|CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]|' Dockerfile
    else
        echo "CMD not found in Dockerfile for $module. Adding CMD line."
        echo 'CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]' >> Dockerfile
    fi

    # Go back to the base directory
    cd /opt/erp_system
done

echo "All modules updated successfully."

