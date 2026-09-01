#!/usr/bin/env python3
"""
Convert old bookworm CSV databases to ShelfSight format.
Only processes first 10 data rows from each file for testing.
Original files remain intact.
"""

import csv
import os
from datetime import datetime

# Source files
KSIAZKI_CSV = "/run/media/sb3x/VENTOY/bookworm-main/ksiazki.csv"
KSIAZKI2_CSV = "/run/media/sb3x/VENTOY/bookworm-main/ksiazki2.csv"

# Output files
OUTPUT_DIR = "/home/sb3x/Code/ShelfSight/src/src/app/converted"
OUTPUT_BOOKS = os.path.join(OUTPUT_DIR, "books_shelfsight.csv")
OUTPUT_CATEGORIES = os.path.join(OUTPUT_DIR, "categories_shelfsight.csv")
OUTPUT_LOCATIONS = os.path.join(OUTPUT_DIR, "locations_shelfsight.csv")

# ShelfSight CSV headers
BOOKS_HEADER = ["id", "title", "author", "location", "category", "status", "createdAt", "updatedAt"]
CATEGORIES_HEADER = ["id", "name"]
LOCATIONS_HEADER = ["id", "name"]

# Status mapping
STATUS_MAP = {
    "dostępna": "Available",
    "available": "Available",
    "not for lending": "Not for lending",
    "wypożyczona": "Borrowed",
    "damaged": "Damaged",
    "missing": "Missing",
}

# Category mapping (normalize Polish names)
CATEGORY_MAP = {
    "Dla dzieci": "Children",
    "Dla Dzieci": "Children",
    "Lektury": "School Reading",
    "Naukowe": "Science",
    "Totalitaryzm": "Totalitarianism",
    "RELIGIJNE": "Religious",
    "Dla Liceum": "High School",
}

def normalize_status(status):
    """Normalize status to ShelfSight format."""
    return STATUS_MAP.get(status.strip().lower(), status.strip().capitalize())

def normalize_category(category):
    """Normalize category to ShelfSight format."""
    cat = category.strip()
    return CATEGORY_MAP.get(cat, cat)

def generate_id():
    """Generate a timestamp-based ID like ShelfSight does."""
    return str(int(datetime.now().timestamp() * 1000))

def get_current_time():
    """Get current time in ISO format."""
    return datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

def convert_ksiazki_csv():
    """Convert ksiazki.csv format to ShelfSight."""
    print("Converting ksiazki.csv...")
    
    books = []
    categories = set()
    locations = set()
    
    with open(KSIAZKI_CSV, 'r', encoding='utf-8-sig') as f:
        # Handle BOM and Windows line endings
        content = f.read().replace('\r\n', '\n').replace('\r', '\n')
        reader = csv.DictReader(content.splitlines())
        for i, row in enumerate(reader):
            if i >= 10:  # Only first 10 rows
                break
            
            book_id = row['ID'].strip()
            title = row['Title'].strip()
            author = row['Author'].strip()
            year = row['Year'].strip()
            genre = row['Genre'].strip()
            status = row['Status'].strip()
            book_row = row['BookRow'].strip()
            
            # Normalize
            category = normalize_category(genre)
            status = normalize_status(status)
            location = book_row if book_row else "Main Shelf"
            
            # Collect unique categories and locations
            categories.add(category)
            locations.add(location)
            
            # Create book entry
            now = get_current_time()
            books.append({
                'id': book_id,
                'title': title,
                'author': author,
                'location': location,
                'category': category,
                'status': status,
                'createdAt': now,
                'updatedAt': now,
            })
            
            print(f"  Row {i+1}: {title} | {author} | {category} | {status} | {location}")
    
    return books, categories, locations

def convert_ksiazki2_csv():
    """Convert ksiazki2.csv format to ShelfSight."""
    print("\nConverting ksiazki2.csv...")
    
    books = []
    categories = set()
    locations = set()
    
    # Try different encodings for the Polish file
    encodings = ['cp1250', 'iso-8859-2', 'latin1']
    content = None
    
    for enc in encodings:
        try:
            with open(KSIAZKI2_CSV, 'r', encoding=enc) as f:
                content = f.read().replace('\r\n', '\n').replace('\r', '\n')
            break
        except UnicodeDecodeError:
            continue
    
    if content is None:
        raise ValueError("Could not decode ksiazki2.csv with any known encoding")
    
    lines = content.splitlines()
    
    # Skip first two lines ("books" and ",123,N")
    # Headers are on line 3 (index 2), data starts from line 4 (index 3)
    data_lines = lines[3:]  # Skip first 3 lines
    
    for i, line in enumerate(data_lines):
        if i >= 10:  # Only first 10 rows
            break
        
        line = line.strip()
        if not line:
            continue
            
        # Parse CSV line (handle quoted fields)
        row = next(csv.reader([line]))
        
        if len(row) < 5:
            continue
            
        title = row[0].strip()
        author = row[1].strip()
        book_id = row[2].strip()
        category = row[3].strip()
        status = row[4].strip()
        
        # Skip if ID is empty
        if not book_id:
            continue
        
        # Normalize
        category = normalize_category(category)
        status = normalize_status(status)
        location = "Main Shelf"  # Default location for ksiazki2
        
        # Collect unique categories and locations
        categories.add(category)
        locations.add(location)
        
        # Create book entry
        now = get_current_time()
        books.append({
            'id': book_id,
            'title': title,
            'author': author,
            'location': location,
            'category': category,
            'status': status,
            'createdAt': now,
            'updatedAt': now,
        })
        
        print(f"  Row {i+1}: {title} | {author} | {category} | {status} | {location}")
    
    return books, categories, locations

def write_csv(filename, header, rows):
    """Write data to CSV file."""
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=header)
        writer.writeheader()
        writer.writerows(rows)
    print(f"  Written: {filename}")

def main():
    print("=" * 60)
    print("Converting old bookworm databases to ShelfSight format")
    print("=" * 60)
    
    # Convert both files
    books1, cats1, locs1 = convert_ksiazki_csv()
    books2, cats2, locs2 = convert_ksiazki2_csv()
    
    # Combine all books
    all_books = books1 + books2
    all_categories = cats1 | cats2
    all_locations = locs1 | locs2
    
    # Create category entries
    category_rows = []
    for i, cat in enumerate(sorted(all_categories)):
        category_rows.append({
            'id': f"cat_{i+1}",
            'name': cat,
        })
    
    # Create location entries
    location_rows = []
    for i, loc in enumerate(sorted(all_locations)):
        location_rows.append({
            'id': f"loc_{i+1}",
            'name': loc,
        })
    
    # Write output files
    print("\nWriting output files...")
    write_csv(OUTPUT_BOOKS, BOOKS_HEADER, all_books)
    write_csv(OUTPUT_CATEGORIES, CATEGORIES_HEADER, category_rows)
    write_csv(OUTPUT_LOCATIONS, LOCATIONS_HEADER, location_rows)
    
    print("\n" + "=" * 60)
    print("Conversion complete!")
    print(f"Books: {len(all_books)}")
    print(f"Categories: {len(category_rows)}")
    print(f"Locations: {len(location_rows)}")
    print(f"Output directory: {OUTPUT_DIR}")
    print("=" * 60)
    print("\nOriginal files remain intact:")
    print(f"  {KSIAZKI_CSV}")
    print(f"  {KSIAZKI2_CSV}")

if __name__ == "__main__":
    main()