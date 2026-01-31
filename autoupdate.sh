# Script to convert PDF pages to images and embed in README.md
# Requires: ghostscript (gs) and imagemagick (convert)

PDF_FILE="CV.pdf"
OUTPUT_DIR="cv_images"
README="README.md"
DPI=150  # Adjust for quality (higher = better quality, larger files)

# Check if PDF exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: $PDF_FILE not found!"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get number of pages using a simpler method
NUM_PAGES=$(pdfinfo "$PDF_FILE" 2>/dev/null | grep "Pages:" | awk '{print $2}')

# Fallback if pdfinfo not available
if [ -z "$NUM_PAGES" ]; then
    echo "Getting page count with ghostscript..."
    NUM_PAGES=$(gs -q -dNOSAFER -dNODISPLAY -c "($PDF_FILE) (r) file runpdfbegin pdfpagecount = quit" 2>/dev/null)
fi

# Another fallback - just convert and count files after
if [ -z "$NUM_PAGES" ] || [ "$NUM_PAGES" -eq 0 ]; then
    echo "Warning: Could not determine page count. Will count after conversion."
    NUM_PAGES="unknown"
fi

echo "Converting pages to PNG..."

# Convert each page to PNG
gs -dSAFER -dBATCH -dNOPAUSE \
   -sDEVICE=png16m \
   -r$DPI \
   -dTextAlphaBits=4 \
   -dGraphicsAlphaBits=4 \
   -sOutputFile="$OUTPUT_DIR/page-%03d.png" \
   "$PDF_FILE"

# Count actual generated files
NUM_PAGES=$(ls "$OUTPUT_DIR"/page-*.png 2>/dev/null | wc -l)

if [ "$NUM_PAGES" -eq 0 ]; then
    echo "Error: No pages were converted!"
    exit 1
fi

echo "Converted $NUM_PAGES pages successfully."

# Create README.md
cat > "$README" << 'EOF'
# Curriculum Vitae

This repository contains my CV in LaTeX format. See the CV.pdf file. Below is a preview of the current version:

---

EOF

# Add each page to README
for i in $(seq 1 "$NUM_PAGES"); do
    PAGE_NUM=$(printf "%03d" "$i")
    echo "![Page $i]($OUTPUT_DIR/page-$PAGE_NUM.png)" >> "$README"
    echo "" >> "$README"
done

echo "Done! README.md created with $NUM_PAGES pages embedded."
