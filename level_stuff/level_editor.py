import tkinter as tk
from tkinter import simpledialog, messagebox
import os
from PIL import Image

root = tk.Tk()
root.title("VIC-20 Level Editor")

# Constants
char_file = "custom_chars_title_screen.txt"
ROWS = 23
COLS = 22
CHAR_IMG_SIZE = 8
ZOOM_FACTOR = 4

# Character and Zero Page Locations
OFFSET_FOR_CHARS_IN_TABLE = 0
ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE = "$10"

# Item codes for binary export
ITEM_CODES = {
    "Wall": 0x01,
    "LaserEmitter": 0x02,
    "LaserReceptor": 0x03,
    "Mirror": 0x04,
    "Portal": 0x05,
}

class Character:
    def __init__(self, name, data):
        self.name = name
        self.data = data

    def __repr__(self):
        return self.name + "_obj"

    def __str__(self):
        return self.name


characters = {}  # Stores Character objects
char_images = {}  # Stores Tkinter PhotoImage objects (zoomed)
selected_character = None
level_grid = [[None for _ in range(COLS)] for _ in range(ROWS)]  # Stores Character objects for the level
level_buttons = [[None for _ in range(COLS)] for _ in range(ROWS)]  # Stores Tkinter buttons


# Load and create character images, with fallback to default item types if file is missing
def load_and_create_character_images():
    if os.path.exists(char_file):
        load_custom_characters()
    else:
        load_default_items()

    update_sidebar()

def load_custom_characters():
    try:
        os.makedirs("./custom_char_images", exist_ok=True)
        with open(char_file, "r") as f:
            lines = f.readlines()
            current_char = []
            char_name = None
            for line in lines:
                line = line.strip()
                if line.startswith("dc.b"):
                    binary = bin(int(line.split("%")[-1], 2))[2:].zfill(8)
                    current_char.append([int(bit) for bit in binary])
                elif current_char and char_name:
                    characters[char_name] = Character(char_name, current_char)
                    create_and_store_image(characters[char_name])
                    current_char = []
                    char_name = None
                elif line and not line.startswith("dc.b"):
                    char_name = line

            # Create an empty character
            characters["0_Empty"] = Character("0_Empty", [[0] * 8 for _ in range(8)])
            create_and_store_image(characters["0_Empty"])

    except FileNotFoundError:
        messagebox.showerror("Error", f"No {char_file} found!")

def load_default_items():
    # Default binary matrix for each item
    default_data = {
        "Wall": [[1] * 8 for _ in range(8)],
        "LaserEmitter": [[1 if x == y else 0 for x in range(8)] for y in range(8)],  # Diagonal pattern
        "LaserReceptor": [[0 if (x + y) % 2 == 0 else 1 for x in range(8)] for y in range(8)],  # Checkerboard pattern
        "Mirror": [[1 if x == 0 or x == 7 or y == 0 or y == 7 else 0 for x in range(8)] for y in range(8)],  # Border
        "Portal": [[0, 1, 1, 0, 0, 1, 1, 0]] * 8,  # Vertical stripes
        "0_Empty": [[0] * 8 for _ in range(8)],  # Empty space
    }

    for name, data in default_data.items():
        char = Character(name, data)
        characters[name] = char
        create_and_store_image(char)


# Create PNG and load the zoomed image for each character
def create_and_store_image(char: Character):
    img_size = (CHAR_IMG_SIZE, CHAR_IMG_SIZE)
    img = Image.new("RGB", img_size, color="white")
    pixels = img.load()

    # Convert binary data to black and white pixels
    for y, row in enumerate(char.data):
        for x, bit in enumerate(row):
            pixels[x, y] = (0, 0, 0) if bit == 1 else (255, 255, 255)

    filename = f"./custom_char_images/{char.name}.png"
    img.save(filename)

    # Create a Tkinter image, pre-zoomed
    tk_image = tk.PhotoImage(file=filename).zoom(ZOOM_FACTOR)
    char_images[char.name] = tk_image


# Update the sidebar with character buttons
def update_sidebar():
    for widget in sidebar.winfo_children():
        widget.destroy()

    sorted_chars = sorted(characters.keys())
    for gang, name in enumerate(sorted_chars):
        char = characters[name]
        char_button = tk.Button(sidebar, text=name, anchor="w", command=lambda char=char: select_character(char))
        char_button.grid(row=gang // 3, column=gang % 3, sticky="ew", padx=0, pady=0)

    for col in range(3):
        sidebar.grid_columnconfigure(col, weight=1)


# Select a character from the sidebar
def select_character(char: Character):
    global selected_character
    selected_character = char

    # Highlight selected character
    for widget in sidebar.winfo_children():
        widget.configure(bg="SystemButtonFace")

    event_widget = root.winfo_containing(root.winfo_pointerx(), root.winfo_pointery())
    if isinstance(event_widget, tk.Button):
        event_widget.configure(bg="lightblue")


# Place the selected character on the grid
def place_character(row, col):
    if selected_character:
        level_grid[row][col] = selected_character
        update_grid_cell(row, col)


# Update the image of a grid cell when clicked
def update_grid_cell(row, col):
    char = level_grid[row][col] or characters["0_Empty"]
    char_image = char_images.get(char.name, char_images["0_Empty"])

    button = level_buttons[row][col]
    button.config(image=char_image)
    button.image = char_image


# Create the grid for the level
def create_grid():
    for r in range(ROWS):
        for c in range(COLS):
            char_image = char_images.get("0_Empty")
            btn = tk.Button(grid_frame, image=char_image, borderwidth=0, command=lambda r=r, c=c: place_character(r, c))
            btn.image = char_image
            btn.grid(row=r, column=c)
            level_buttons[r][c] = btn


def export_level_binary():
    level_name = simpledialog.askstring("Export Level", "Name for the level? (will overwrite existing files!)")
    if level_name:
        # Ensure the levels directory exists
        os.makedirs("./levels", exist_ok=True)
        
        # Open the file in binary write mode
        with open(f"./levels/{level_name}.bin", "wb") as f:
            characters_used_in_level = {}

            for row_num, row in enumerate(level_grid):
                for col, char in enumerate(row):
                    if isinstance(char, Character) and char.name in ITEM_CODES:
                        if char not in characters_used_in_level:
                            characters_used_in_level[char] = [(row_num, col)]
                        else:
                            characters_used_in_level[char].append((row_num, col))

            # Write binary data with item code and calculated screen memory address
            for char, positions in characters_used_in_level.items():
                item_code = ITEM_CODES.get(char.name, 0x00)
                for row, col in positions:
                    # Calculate VIC-20 screen memory address
                    screen_offset = 0x1E00 + (row * 22) + col
                    # Write item code, low byte of address, high byte of address
                    f.write(bytes([item_code, screen_offset & 0xFF, (screen_offset >> 8) & 0xFF]))
                    # The screen address is saved as two bytes (low byte first, high byte second) to match the 16-bit address format used by the VIC-20’s 6502 processor.

        messagebox.showinfo("Export Level", f"Level {level_name} exported successfully with VIC-20 screen addresses!")




def populate_right_sidebar():
    for widget in sidebar2.winfo_children():
        widget.destroy()

    export_button = tk.Button(sidebar2, text="Export Binary Level", command=export_level_binary)
    export_button.pack(fill=tk.X, padx=5, pady=5)


# Initialize the GUI
if __name__ == "__main__":
    sidebar = tk.Frame(root, bg="lightgrey")
    sidebar.grid(row=0, column=0, rowspan=ROWS, sticky="ns")

    grid_frame = tk.Frame(root, width=2000, height=1150)
    grid_frame.grid(row=0, column=1, padx=5, pady=5)

    sidebar2 = tk.Frame(root, width=100, height=600, bg="lightgrey")
    sidebar2.grid(row=0, column=2, rowspan=ROWS, sticky="ns")
    sidebar2.grid_propagate(False)

    # Load characters, create PNGs, and load images into memory
    load_and_create_character_images()

    # Create the grid for placing characters
    create_grid()

    # Populate right sidebar with export button
    populate_right_sidebar()

    print("Editor Initialized")
    root.mainloop()
