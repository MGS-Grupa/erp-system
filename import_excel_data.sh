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

DATA

# Kreiranje Python skripte za obradu CSV datoteke i unos podataka u bazu podataka
cat <<PYTHON_SCRIPT > import_data.py
import pandas as pd
from sqlalchemy import create_engine

# Putanja do CSV datoteke
csv_file = "$CSV_FILE"

# Učitavanje CSV datoteke
data = pd.read_csv(csv_file)

# Prikaz prvih nekoliko redaka za provjeru
print("Podaci iz CSV datoteke:")
print(data.head())

# Spajanje na bazu podataka PostgreSQL
engine = create_engine('postgresql+psycopg2://erp_user:erp_password@localhost:5432/erp_db')

# Unos podataka u tablicu 'zalihe_materijala' u bazi podataka
data.to_sql('zalihe_materijala', engine, if_exists='replace', index=False)

print("Podaci su uspješno uneseni u bazu podataka.")
PYTHON_SCRIPT

# Pokretanje Python skripte
echo "Pokretanje skripte za obradu CSV podataka..."
python3 import_data.py
echo "=== Završetak obrade CSV podataka ==="

# Brisanje privremene Python skripte
rm import_data.py
rm $CSV_FILE

# Deaktivacija virtualnog okruženja
deactivate
