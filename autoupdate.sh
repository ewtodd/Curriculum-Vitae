# Script to convert PDF pages to images and embed in README.md
# Requires: poppler_utils (pdftoppm)

PDF_FILE="CV.pdf"
OUTPUT_DIR="cv_images"
README="README.md"
DPI=300  # High quality

# Check if PDF exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: $PDF_FILE not found!"
    exit 1
fi

# Create output directory (clean it first to avoid duplicates)
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Converting pages to PNG with high quality font rendering..."

# Use pdftoppm for best quality (preserves fonts perfectly)
# Output format is page-1.png, page-2.png, etc.
pdftoppm -png -r $DPI -aa yes -aaVector yes "$PDF_FILE" "$OUTPUT_DIR/page"

# Rename files to zero-padded format (page-001.png, page-002.png, etc.)
counter=1
for file in "$OUTPUT_DIR"/page-*.png; do
    if [ -f "$file" ]; then
        newname=$(printf "$OUTPUT_DIR/page-%03d.png" "$counter")
        if [ "$file" != "$newname" ]; then
            mv "$file" "$newname"
        fi
        ((counter++))
    fi
done

# Count actual PNG files
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
    echo "## Page $i" >> "$README"
    echo "" >> "$README"
    echo "![Page $i]($OUTPUT_DIR/page-$PAGE_NUM.png)" >> "$README"
    echo "" >> "$README"
done

echo "Done! $README created with $NUM_PAGES pages embedded."
