#!/bin/bash

echo "=== Ažuriranje MGS ERP Sustava ==="

# Definiranje modula
modules=("projekti" "kvaliteta" "prodaja" "proizvodnja" "projektiranje" "nabava" "skladiste")
base_dir="/opt/erp_system"

# Ažuriraj requirements.txt za svaki modul
for module in "${modules[@]}"; do
  echo "Ažuriram requirements.txt za modul: $module"
  module_dir="$base_dir/$module"
  
  # Provjeri postoji li direktorij modula
  if [ -d "$module_dir" ]; then
    cat <<EOF > "$module_dir/requirements.txt"
Flask==2.0.3
Flask-SQLAlchemy==2.4.4
SQLAlchemy==1.3.23
Werkzeug==2.0.3
gunicorn==20.1.0
EOF
  else
    echo "Direktorij za modul $module ne postoji. Preskačem."
  fi
done

# Zaustavi sve postojeće kontejnere i ukloni stare slike
echo "Zaustavljam sve postojeće kontejnere i brišem stare slike..."
docker-compose down

# Ponovno izgradi Docker slike i pokreni kontejnere
echo "Ponovno izgrađujem i pokrećem kontejnere..."
docker-compose up -d --build

# Provjera statusa kontejnera
echo "Provjeravam status kontejnera..."
docker-compose ps
docker-compose logs

echo "=== MGS ERP Sustav je ažuriran i pokrenut! ==="
#!/bin/bash

echo "=== Ažuriranje MGS ERP Sustava ==="

# Definiranje modula
modules=("projekti" "kvaliteta" "prodaja" "proizvodnja" "projektiranje" "nabava" "skladiste")
base_dir="/opt/erp_system"

# Ažuriraj requirements.txt za svaki modul
for module in "${modules[@]}"; do
  echo "Ažuriram requirements.txt za modul: $module"
  module_dir="$base_dir/$module"
  
  # Provjeri postoji li direktorij modula
  if [ -d "$module_dir" ]; then
    cat <<EOF > "$module_dir/requirements.txt"
Flask==2.0.3
Flask-SQLAlchemy==2.5.1
Werkzeug==2.0.3
gunicorn==20.1.0
EOF
  else
    echo "Direktorij za modul $module ne postoji. Preskačem."
  fi
done

# Zaustavi sve postojeće kontejnere i ukloni stare slike
echo "Zaustavljam sve postojeće kontejnere i brišem stare slike..."
docker-compose down

# Ponovno izgradi Docker slike i pokreni kontejnere
echo "Ponovno izgrađujem i pokrećem kontejnere..."
docker-compose up -d --build

# Provjera statusa kontejnera
echo "Provjeravam status kontejnera..."
docker-compose ps
docker-compose logs

echo "=== MGS ERP Sustav je ažuriran i pokrenut! ==="

