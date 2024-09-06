#!/bin/bash

# Definiranje modula
modules=("projekti" "kvaliteta" "prodaja")

# Kreiranje stranica za svaki modul
for module in "${modules[@]}"; do
  echo "Kreiranje stranice za modul: $module"
  
  # Kreiranje direktorija za modul ako ne postoji
  mkdir -p src/pages/$module
  
  # Kreiranje osnovne komponente za svaki modul
  cat <<EOF > src/pages/$module/${module^}.js
import React from 'react';

const ${module^} = () => {
  return (
    <div>
      <h1>Welcome to the $module module!</h1>
      <p>This is the main page for the $module module.</p>
    </div>
  );
};

export default ${module^};
EOF

  echo "Stranica $module kreirana u src/pages/$module/${module^}.js"
done

echo "Dodavanje ruta u src/App.js..."

# Dodavanje ruta u src/App.js ako već nije dodano
if ! grep -q "import { BrowserRouter as Router" src/App.js; then
  sed -i "/import React from/a import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';" src/App.js
fi

for module in "${modules[@]}"; do
  # Dodavanje import linije u App.js ako ne postoji
  if ! grep -q "import ${module^} from './pages/$module/${module^}';" src/App.js; then
    sed -i "/import { BrowserRouter as Router/a import ${module^} from './pages/$module/${module^}';" src/App.js
  fi
done

# Dodavanje ruta u App.js
if ! grep -q "<Router>" src/App.js; then
  sed -i "/<App \/>/i <Router>\n  <Routes>\n    <Route path=\"/projekti\" element={<Projekti />} />\n    <Route path=\"/kvaliteta\" element={<Kvaliteta />} />\n    <Route path=\"/prodaja\" element={<Prodaja />} />\n  </Routes>\n</Router>" src/App.js
fi

echo "Uspješno dodano!"

