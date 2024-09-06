#!/bin/bash

echo "=== Postavljanje MGS ERP Sustava ==="

# Definiranje modula i njihovih portova
declare -A modules=( ["projekti"]="5000" ["kvaliteta"]="5001" ["prodaja"]="5002" ["proizvodnja"]="5003" ["projektiranje"]="5004" ["nabava"]="5005" ["skladiste"]="5006" )
base_dir="/opt/erp_system"

# 1. Kreiraj osnovni direktorij ako ne postoji
if [ ! -d "$base_dir" ]; then
  mkdir -p "$base_dir"
  echo "Kreiran direktorij: $base_dir"
fi

cd "$base_dir"

# 2. Kloniranje repozitorija i instalacija ovisnosti za svaki modul
for module in "${!modules[@]}"; do
  echo "Postavljam modul: $module"
  if [ ! -d "$module" ]; then
    mkdir $module
  fi
  cd $base_dir/$module

  # 3. Kreiraj Dockerfile ako ne postoji
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

  # 4. Kreiraj requirements.txt ako ne postoji
  cat <<EOF > requirements.txt
Flask==2.0.3
Flask-SQLAlchemy==2.5.1
gunicorn==20.1.0
EOF

  # 5. Kreiraj osnovnu `api.py` datoteku ako ne postoji
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

# 6. Kreiranje i postavljanje docker-compose.yml datoteke
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

# 7. Pokretanje Docker Compose-a
echo "Pokrećem Docker Compose..."
docker-compose down --rmi all
docker-compose up -d --build

# 8. Konfiguriranje i pokretanje frontenda
frontend_dir="$base_dir/frontend/erp-frontend"
if [ ! -d "$frontend_dir" ]; then
  mkdir -p "$frontend_dir"
  cd "$base_dir/frontend"
  npx create-react-app erp-frontend
fi

cd "$frontend_dir"
npm install
npm start &

echo "=== MGS ERP Sustav je uspješno postavljen! ==="
echo "Provjerite aplikaciju na http://157.230.103.28:3000"
#!/bin/bash

echo "=== Postavljanje MGS ERP Sustava ==="

# Definiranje modula i njihovih portova
declare -A modules=( ["projekti"]="5000" ["kvaliteta"]="5001" ["prodaja"]="5002" ["proizvodnja"]="5003" ["projektiranje"]="5004" )
base_dir="/opt/erp_system"

# 1. Kreiraj osnovni direktorij ako ne postoji
if [ ! -d "$base_dir" ]; then
  mkdir -p "$base_dir"
  echo "Kreiran direktorij: $base_dir"
fi

cd "$base_dir"

# 2. Kloniranje repozitorija i instalacija ovisnosti za svaki modul
for module in "${!modules[@]}"; do
  echo "Postavljam modul: $module"
  if [ ! -d "$module" ]; then
    git clone https://github.com/tvoj-repozitorij/$module.git $base_dir/$module
  fi
  cd $base_dir/$module

  # 3. Kreiraj Dockerfile ako ne postoji
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

  # 4. Kreiraj requirements.txt ako ne postoji
  cat <<EOF > requirements.txt
Flask==2.0.3
Flask-SQLAlchemy==2.5.1
gunicorn==20.1.0
EOF

  # 5. Instalacija ovisnosti
  pip install -r requirements.txt

  cd $base_dir
done

# 6. Kreiranje i postavljanje docker-compose.yml datoteke
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
EOF
done

# 7. Pokretanje Docker Compose-a
echo "Pokrećem Docker Compose..."
docker-compose up -d --build

# 8. Konfiguriranje i pokretanje frontenda
frontend_dir="$base_dir/frontend/erp-frontend"
if [ ! -d "$frontend_dir" ]; then
  mkdir -p "$frontend_dir"
  cd "$base_dir/frontend"
  npx create-react-app erp-frontend
fi

cd "$frontend_dir"
npm install
npm start &

echo "=== MGS ERP Sustav je uspješno postavljen! ==="
echo "Provjerite aplikaciju na http://157.230.103.28:3000"

