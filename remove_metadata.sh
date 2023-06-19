#!/bin/bash

# Aktuelles Verzeichnis
dir_path=$(pwd)

# Überprüfe, ob exiftool und qpdf installiert sind
if ! command -v exiftool &> /dev/null
then
    echo "exiftool ist nicht installiert. Installiere es jetzt..."
    brew install exiftool
fi

if ! command -v qpdf &> /dev/null
then
    echo "qpdf ist nicht installiert. Installiere es jetzt..."
    brew install qpdf
fi

# Durchlaufe alle PDF-Dateien im Verzeichnis und Unterordnern
find "$dir_path" -name '*.pdf' -type f | while read -r file
do
  echo "Bearbeite Datei: $file"

  # Entferne alle Metadaten mit exiftool
  exiftool -all:all= "$file"

  # Erstelle eine neue PDF-Datei mit qpdf, um sicherzustellen, dass die Metadatenänderungen irreversibel sind
  qpdf "$file" "${file%.*}_temp.pdf"

  # Erstelle linearisierte Kopie der Datei mit qpdf
  qpdf --linearize "${file%.*}_temp.pdf" "${file%.*}_no-metadata.pdf"

  # Lösche die temporäre Datei
  rm "${file%.*}_temp.pdf"

  echo "Bearbeitung abgeschlossen für: $file"

  # Lösche die ursprüngliche Datei
  rm "$file"
done
