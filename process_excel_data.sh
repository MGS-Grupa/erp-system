#!/bin/bash

echo "=== Početak obrade Excel podataka ==="

# Korak 1: Postavljanje virtualnog okruženja
echo "Postavljanje virtualnog okruženja..."
python3 -m venv venv
source venv/bin/activate

# Korak 2: Instalacija potrebnih Python paketa
echo "Instalacija Python paketa..."
pip install pandas openpyxl sqlalchemy psycopg2-binary

# Korak 3: Python skripta za obradu podataka
echo "Pokretanje skripte za obradu Excel podataka..."
python3 <<EOF
import pandas as pd
from sqlalchemy import create_engine

# Putanja do Excel fajla
file_path = '/mnt/data/Zalihe_materijala.xls'

# Učitaj sve listove u Excel fajlu
excel_data = pd.ExcelFile(file_path)
sheet_names = excel_data.sheet_names

# Prikaz svih listova
print("Listovi u Excel fajlu:", sheet_names)

# Spoj na bazu podataka (prilagodite prema svojoj bazi podataka)
engine = create_engine('postgresql://erp_user:erp_password@localhost:5432/erp_system')

# Pročitaj i unesi svaki list u SQL bazu podataka
for sheet in sheet_names:
    df = pd.read_excel(file_path, sheet_name=sheet)
    df.to_sql(sheet.lower(), engine, index=False, if_exists='replace')

print("Uspješan uvoz podataka u bazu podataka.")
EOF

echo "=== Završetak obrade Excel podataka ==="

