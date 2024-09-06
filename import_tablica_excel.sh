#!/bin/bash

# Aktivacija virtualnog okruženja
source /opt/erp_system/venv/bin/activate

# Provjera je li instaliran Python paket openpyxl (za rad s Excel datotekama)
pip install --upgrade pip
pip install pandas openpyxl sqlalchemy psycopg2-binary

# Naziv datoteke
EXCEL_FILE="Materijali.xlsx"

# Kreiranje Excel datoteke s podacima unutar skripte
cat <<EOF > $EXCEL_FILE
<OVDJE ĆEMO UBACITI PODATKE IZ EXCEL DATOTEKE U CSV FORMATU>
EOF

# Kreiranje Python skripte za obradu Excel datoteke i unos podataka u bazu podataka
cat <<EOF > import_data.py
import pandas as pd
from sqlalchemy import create_engine

# Putanja do Excel datoteke
excel_file = "$EXCEL_FILE"

# Učitavanje Excel datoteke
data = pd.read_excel(excel_file)

# Prikaz prvih nekoliko redaka za provjeru
print("Podaci iz Excel datoteke:")
print(data.head())

# Spajanje na bazu podataka PostgreSQL
engine = create_engine('postgresql+psycopg2://erp_user:erp_password@localhost:5432/erp_db')

# Unos podataka u tablicu 'zalihe_materijala' u bazi podataka
data.to_sql('zalihe_materijala', engine, if_exists='replace', index=False)

print("Podaci su uspješno uneseni u bazu podataka.")
EOF

# Pokretanje Python skripte
echo "Pokretanje skripte za obradu Excel podataka..."
python3 import_data.py
echo "=== Završetak obrade Excel podataka ==="

# Brisanje privremene Python skripte
rm import_data.py
rm $EXCEL_FILE

# Deaktivacija virtualnog okruženja
deactivate

