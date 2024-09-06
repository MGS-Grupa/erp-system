#!/bin/bash

echo "=== Pokrećem MGS ERP Sustav ==="

# Definiranje modula i njihovih portova
declare -A modules=( ["projekti"]="5000" ["kvaliteta"]="5001" ["prodaja"]="5002" ["proizvodnja"]="5003" ["projektiranje"]="5004" ["nabava"]="5005" ["skladiste"]="5006" )
base_dir="/opt/erp_system"

# Provjeri postoji li osnovni direktorij
if [ ! -d "$base_dir" ]; then
  echo "Direktorij $base_dir ne postoji. Kreiram ga..."
  mkdir -p "$base_dir"
fi

cd "$base_dir"

# 1. Zaustavi sve postojeće kontejnere i ukloni stare slike
echo "Zaustavljam sve postojeće kontejnere i brišem stare slike..."
docker-compose down

# 2. Očisti mreže koje nisu u upotrebi
echo "Čišćenje Docker mreža..."
docker network prune -f

# 3. Kloniranje repozitorija i instalacija ovisnosti za svaki modul
for module in "${!modules[@]}"; do
  echo "Postavljam modul: $module"

  # Provjeri postoji li direktorij za modul
  if [ ! -d "$module" ]; then
    mkdir $module
  fi

  cd $base_dir/$module

  # Kreiraj Dockerfile za svaki modul
  cat <<EOF > Dockerfile
FROM python:3.8-slim

WORKDIR /app

RUN python -m venv venv

COPY requirements.txt .
RUN ./venv/bin/pip install --upgrade pip && ./venv/bin/pip install -r requirements.txt && ./venv/bin/pip install gunicorn

COPY . /app

EXPOSE ${modules[$module]}

CMD ["./venv/bin/gunicorn", "--bind", "0.0.0.0:${modules[$module]}", "api:app"]
EOF

  # Kreiraj requirements.txt za svaki modul
  cat <<EOF > requirements.txt
Flask==2.0.3
Flask-SQLAlchemy==2.5.1
gunicorn==20.1.0
EOF

  # Kreiraj osnovnu `api.py` datoteku za svaki modul
  cat <<EOF > api.py
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
db = SQLAlchemy(app)

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the $module module!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=${modules[$module]})
EOF

  cd $base_dir
done

# 4. Kreiranje i postavljanje docker-compose.yml datoteke
cat <<EOF > docker-compose.yml
version: '3'
services:
EOF

for module in "${!modules[@]}"; do
  cat <<EOF >> docker-compose.yml
  $module:
    build: ./$module
    ports:
      - "${modules[$module]}:${modules[$module]}"
    environment:
      - FLASK_ENV=production
EOF
done

# 5. Pokretanje Docker Compose-a
echo "Pokrećem Docker Compose za sve module..."
docker-compose up -d --build

# 6. Provjera statusa kontejnera
echo "Provjeravam status kontejnera..."
docker ps

# 7. Konfiguriranje i pokretanje frontenda
frontend_dir="$base_dir/frontend/erp-frontend"
if [ ! -d "$frontend_dir" ]; then
  echo "Kreiram frontend aplikaciju..."
  mkdir -p "$frontend_dir"
  cd "$base_dir/frontend"
  npx create-react-app erp-frontend
fi

cd "$frontend_dir"
npm install
npm start &

echo "=== MGS ERP Sustav je uspješno postavljen i pokrenut! ==="
echo "Provjerite aplikaciju na http://157.230.103.28:3000"
#!/bin/bash

echo "=== Pokrećem MGS ERP Sustav ==="

# Definiranje modula i njihovih portova
declare -A modules=( ["projekti"]="5000" ["kvaliteta"]="5001" ["prodaja"]="5002" ["proizvodnja"]="5003" ["projektiranje"]="5004" ["nabava"]="5005" ["skladiste"]="5006" )
base_dir="/opt/erp_system"

# Provjeri postoji li osnovni direktorij
if [ ! -d "$base_dir" ]; then
  echo "Direktorij $base_dir ne postoji. Kreiram ga..."
  mkdir -p "$base_dir"
fi

cd "$base_dir"

# 1. Zaustavi sve postojeće kontejnere i ukloni stare slike
echo "Zaustavljam sve postojeće kontejnere i brišem stare slike..."
docker-compose down --rmi all

# 2. Kloniranje repozitorija i instalacija ovisnosti za svaki modul
for module in "${!modules[@]}"; do
  echo "Postavljam modul: $module"

  # Provjeri postoji li direktorij za modul
  if [ ! -d "$module" ]; then
    mkdir $module
  fi

  cd $base_dir/$module

  # Kreiraj Dockerfile za svaki modul
  cat <<EOF > Dockerfile
FROM python:3.8-slim

WORKDIR /app

RUN python -m venv venv

COPY requirements.txt .
RUN ./venv/bin/pip install --upgrade pip && ./venv/bin/pip install -r requirements.txt && ./venv/bin/pip install gunicorn

COPY . /app

EXPOSE ${modules[$module]}

CMD ["./venv/bin/gunicorn", "--bind", "0.0.0.0:${modules[$module]}", "api:app"]
EOF

  # Kreiraj requirements.txt za svaki modul
  cat <<EOF > requirements.txt
Flask==2.0.3
Flask-SQLAlchemy==2.5.1
gunicorn==20.1.0
EOF

  # Kreiraj osnovnu `api.py` datoteku za svaki modul
  cat <<EOF > api.py
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
db = SQLAlchemy(app)

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the $module module!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=${modules[$module]})
EOF

  cd $base_dir
done

# 3. Kreiranje i postavljanje docker-compose.yml datoteke
cat <<EOF > docker-compose.yml
version: '3'
services:
EOF

for module in "${!modules[@]}"; do
  cat <<EOF >> docker-compose.yml
  $module:
    build: ./$module
    ports:
      - "${modules[$module]}:${modules[$module]}"
    environment:
      - FLASK_ENV=production
EOF
done

# 4. Pokretanje Docker Compose-a
echo "Pokrećem Docker Compose za sve module..."
docker-compose up -d --build

# 5. Provjera statusa kontejnera
echo "Provjeravam status kontejnera..."
docker ps

# 6. Konfiguriranje i pokretanje frontenda
frontend_dir="$base_dir/frontend/erp-frontend"
if [ ! -d "$frontend_dir" ]; then
  echo "Kreiram frontend aplikaciju..."
  mkdir -p "$frontend_dir"
  cd "$base_dir/frontend"
  npx create-react-app erp-frontend
fi

cd "$frontend_dir"
npm install
npm start &

echo "=== MGS ERP Sustav je uspješno postavljen i pokrenut! ==="
echo "Provjerite aplikaciju na http://157.230.103.28:3000"

