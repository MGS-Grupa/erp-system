#!/bin/bash

# Definiraj module
modules=("projekti" "kvaliteta" "prodaja")

# Ažuriranje Dockerfile i requirements.txt za svaki modul
for module in "${modules[@]}"
do
  echo "Processing module: $module"

  # Putanja do Dockerfile i requirements.txt
  dockerfile_path="/opt/erp_system/$module/Dockerfile"
  requirements_path="/opt/erp_system/$module/requirements.txt"

  # Ažuriranje requirements.txt - dodavanje gunicorn ako već nije dodano
  if ! grep -q "gunicorn" "$requirements_path"; then
    echo "gunicorn" >> "$requirements_path"
    echo "Added gunicorn to $requirements_path"
  else
    echo "gunicorn already exists in $requirements_path"
  fi

  # Ažuriranje Dockerfile
  echo "Updating Dockerfile for $module"
  cat <<EOF > "$dockerfile_path"
FROM python:3.8-slim

WORKDIR /app

# Kreiranje virtualnog okruženja
RUN python -m venv venv

# Kopiranje requirements.txt i instalacija ovisnosti
COPY requirements.txt .
RUN ./venv/bin/pip install --upgrade pip && ./venv/bin/pip install -r requirements.txt

# Instalacija gunicorn-a
RUN ./venv/bin/pip install gunicorn

# Kopiranje aplikacijskih datoteka
COPY . /app

# Eksponiranje porta
EXPOSE 5000

# Pokretanje aplikacije pomoću gunicorn-a
CMD ["./venv/bin/gunicorn", "--bind", "0.0.0.0:5000", "api:app"]
EOF

  echo "Updated Dockerfile for $module"
done

# Pokretanje Docker Compose za ponovno izgradnju i pokretanje kontejnera
echo "Building and starting all services with Docker Compose..."
sudo docker-compose down --rmi all
sudo docker-compose up -d --build

echo "Done!"

