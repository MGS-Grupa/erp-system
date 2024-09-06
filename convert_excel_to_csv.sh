#!/bin/bash

# Naziv Excel datoteke
EXCEL_FILE="Materijali.xlsx"
CSV_FILE="Materijali.csv"

# Provjera je li instaliran Python paket openpyxl (za rad s Excel datotekama)
echo "Provjeravam potrebne pakete..."
pip install --upgrade pip
pip install pandas openpyxl

# Kreiranje Python skripte za konverziju Excel u CSV
cat <<EOF > convert_excel_to_csv.py
import pandas as pd

# Putanja do Excel datoteke
excel_file = "$EXCEL_FILE"

# Učitavanje Excel datoteke i pretvaranje u CSV
data = pd.read_excel(excel_file)
data.to_csv("$CSV_FILE", index=False)

print(f"Datoteka {excel_file} je uspješno konvertirana u CSV datoteku {CSV_FILE}.")
EOF

# Pokretanje Python skripte za konverziju Excel u CSV
echo "Pokrećem konverziju Excel datoteke u CSV..."
python3 convert_excel_to_csv.py
echo "Konverzija je završena."

# Čitanje CSV datoteke i priprema za umetanje u skriptu
echo "Čitam CSV datoteku i pripremam podatke za umetanje..."
CSV_DATA=$(cat "$CSV_FILE")

# Kreiranje završne Bash skripte s CSV podacima
FINAL_SCRIPT="import_excel_data.sh"
cat <<EOF > $FINAL_SCRIPT
#!/bin/bash

# Aktivacija virtualnog okruženja
source /opt/erp_system/venv/bin/activate

# Provjera je li instaliran Python paket openpyxl (za rad s Excel datotekama)
pip install --upgrade pip
pip install pandas openpyxl sqlalchemy psycopg2-binary

# Naziv CSV datoteke
CSV_FILE="Materijali.csv"

# Kreiranje CSV datoteke s podacima unutar skripte
cat <<DATA > \$CSV_FILE
$CSV_DATA
DATA

# Kreiranje Python skripte za obradu CSV datoteke i unos podataka u bazu podataka
cat <<PYTHON_SCRIPT > import_data.py
import pandas as pd
from sqlalchemy import create_engine

# Putanja do CSV datoteke
csv_file = "\$CSV_FILE"

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
rm \$CSV_FILE

# Deaktivacija virtualnog okruženja
deactivate
EOF

echo "Završna skripta '$FINAL_SCRIPT' je generirana."
echo "Možete je pokrenuti sa: bash $FINAL_SCRIPT"

# Brisanje privremene Python skripte
rm convert_excel_to_csv.py
rm "$CSV_FILE"

