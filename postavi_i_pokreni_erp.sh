#!/bin/bash

echo "=== Pokretanje ERP sustava MGS Grupa ==="

# Provjera je li PostgreSQL servis pokrenut
echo "Provjera je li PostgreSQL servis pokrenut..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Kreiranje baze podataka i korisnika ako već nisu kreirani
echo "Kreiranje baze podataka i korisnika..."
sudo -u postgres psql -c "CREATE DATABASE erp_db;" 2>/dev/null
sudo -u postgres psql -c "CREATE USER erp_user WITH PASSWORD 'securepassword';" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE erp_db TO erp_user;"

# Instalacija potrebnih Python ovisnosti unutar virtualnog okruženja
echo "Instalacija Python ovisnosti za svaki modul..."
source venv/bin/activate
pip install -r requirements.txt

# Pokretanje Docker kontejnera za sve module
echo "Pokretanje Docker kontejnera..."
sudo docker-compose up --build -d

# Provjera statusa kontejnera
echo "Provjeravam status kontejnera..."
sudo docker ps

# Uvoz podataka u bazu
echo "Pokretanje skripte za uvoz podataka..."
python3 import_data.py

# Konfiguracija i pokretanje Nginx-a
echo "Konfiguracija i pokretanje Nginx-a..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "=== ERP sustav MGS Grupa je pokrenut i spreman za upotrebu! ==="

