#!/bin/bash

# Aktivacija virtualnog okruženja
source /opt/erp_system/venv/bin/activate

# Provjera je li instaliran Python paket openpyxl (za rad s Excel datotekama)
pip install --upgrade pip
pip install pandas openpyxl sqlalchemy psycopg2-binary

# Naziv CSV datoteke
CSV_FILE="Materijali.csv"

# Kreiranje CSV datoteke s podacima unutar skripte
cat <<DATA > $CSV_FILE
Materijal,Opis,Kolicina,JedinicaMjere,Cijena
čelik,AISI 304,1000,kg,5.5
aluminij,6061-T6,500,kg,3.2
bakrena žica,Cu ETP,300,m,0.15
srebro,AG 999,50,g,0.8
PVC cijev,50mm promjer,100,m,0.1
DATA

# Provjera sadrži li CSV datoteka podatke
if [ ! -s "$CSV_FILE" ]; then
    echo "CSV datoteka je prazna ili neispravna. Provjerite datoteku: $CSV_FILE"
    exit 1
fi

# Provjera je li PostgreSQL pokrenut
echo "Provjera je li PostgreSQL servis pokrenut..."
sudo systemctl status postgresql >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "PostgreSQL servis nije pokrenut. Pokrećem PostgreSQL servis..."
    sudo systemctl start postgresql
fi

# Provjera postoji li baza podataka 'erp_db'
DB_NAME="erp_db"
DB_USER="erp_user"
DB_PASSWORD="erp_password"

sudo -u postgres psql -c "\l" | grep $DB_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Kreiranje baze podataka '$DB_NAME'..."
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
else
    echo "Baza podataka '$DB_NAME' već postoji."
fi

# Kreiranje Python skripte za obradu CSV datoteke i unos podataka u bazu podataka
cat <<EOF > import_data.py
import pandas as pd
from sqlalchemy import create_engine

# Putanja do CSV datoteke
csv_file = "$CSV_FILE"

# Učitavanje CSV datoteke
try:
    data = pd.read_csv(csv_file)
    if data.empty:
        raise ValueError("CSV datoteka je prazna.")
except Exception as e:
    print(f"Greška prilikom učitavanja CSV datoteke: {e}")
    exit(1)

# Prikaz prvih nekoliko redaka za provjeru
print("Podaci iz CSV datoteke:")
print(data.head())

# Spajanje na bazu podataka PostgreSQL
engine = create_engine('postgresql+psycopg2://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME')

# Unos podataka u tablicu 'zalihe_materijala' u bazi podataka
data.to_sql('zalihe_materijala', engine, if_exists='replace', index=False)

print("Podaci su uspješno uneseni u bazu podataka.")
EOF

# Pokretanje Python skripte
echo "Pokretanje skripte za obradu CSV podataka..."
python3 import_data.py
echo "=== Završetak obrade CSV podataka ==="

# Brisanje privremene Python skripte
rm import_data.py
rm $CSV_FILE

# Deaktivacija virtualnog okruženja
deactivate

