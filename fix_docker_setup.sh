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
        # Change CMD line to use gunicorn
        sed -i 's|CMD .*|CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]|' Dockerfile
    else
        echo "CMD not found in Dockerfile for $module. Adding CMD line."
        # Add CMD line to Dockerfile
        echo 'CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]' >> Dockerfile
    fi

    # Ensure gunicorn is installed in Dockerfile
    if ! grep -q "RUN ./venv/bin/pip install gunicorn" Dockerfile; then
        echo "Installing gunicorn in Dockerfile for $module"
        # Add gunicorn installation line
        sed -i '/RUN .\/venv\/bin\/pip install/r'<(echo 'RUN ./venv/bin/pip install gunicorn') Dockerfile
    fi

    # Go back to the base directory
    cd /opt/erp_system
done

echo "All modules updated successfully."

# Rebuild and restart Docker containers
echo "Rebuilding Docker containers..."
sudo docker-compose down --rmi all
sudo docker-compose up -d --build

echo "Done!"
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
        # Change CMD line to use gunicorn
        sed -i 's|CMD .*|CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]|' Dockerfile
    else
        echo "CMD not found in Dockerfile for $module. Adding CMD line."
        # Add CMD line to Dockerfile
        echo 'CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]' >> Dockerfile
    fi

    # Install gunicorn in Dockerfile
    if ! grep -q "gunicorn" Dockerfile; then
        echo "Installing gunicorn in Dockerfile for $module"
        sed -i '/pip install/r'<(echo 'RUN ./venv/bin/pip install gunicorn') Dockerfile
    fi

    # Go back to the base directory
    cd /opt/erp_system
done

echo "All modules updated successfully."

# Rebuild and restart Docker containers
echo "Rebuilding Docker containers..."
sudo docker-compose down --rmi all
sudo docker-compose up -d --build

echo "Done!"

