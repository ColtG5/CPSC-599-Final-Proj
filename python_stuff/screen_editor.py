import tkinter as tk
from tkinter import simpledialog, messagebox
import os
from PIL import Image

root = tk.Tk()
root.title("vic-20 level editor")

custom_char_table_file = "./character_tables/char_table.s"
char_images_folder = "./custom_char_images"
screens_folder = "./screens"

ROWS = 23
COLS = 22
CHAR_IMG_SIZE = 8
ZOOM_FACTOR = 4

ITEM_CODES = {
    "Wall": 0x01,
    "laser_shooter": 0x02,
    "laser_receptor": 0x03,
    "reflector_1": 0x04,
    "reflector_2": 0x05,
    "portal": 0x06,
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

# Load and create character images
def load_and_create_character_images():
    global empty_character
    try:
        os.makedirs(char_images_folder, exist_ok=True)
        with open(custom_char_table_file, "r") as f:
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
                    if char_name == "empty_character":
                        empty_character = characters[char_name]
                    current_char = []
                    char_name = None

                elif line and not line.startswith("dc.b"):
                    char_name = line

            update_sidebar()
    except FileNotFoundError:
        messagebox.showerror("Error", f"No {custom_char_table_file} found!")

# Create PNG and load the zoomed image for each character
def create_and_store_image(char: Character):
    img_size = (CHAR_IMG_SIZE, CHAR_IMG_SIZE)
    img = Image.new("RGB", img_size, color="white")
    pixels = img.load()

    for y, row in enumerate(char.data):
        for x, bit in enumerate(row):
            pixels[x, y] = (0, 0, 0) if bit == 1 else (255, 255, 255)

    filename = f"{char_images_folder}/{char.name}.png"
    img.save(filename)
    tk_image = tk.PhotoImage(file=filename).zoom(ZOOM_FACTOR)
    char_images[char.name] = tk_image

# Update the sidebar with character buttons
def update_sidebar():
    for widget in sidebar.winfo_children():
        widget.destroy()

    sorted_chars = sorted(characters.keys())
    for i, name in enumerate(sorted_chars):
        char = characters[name]
        char_button = tk.Button(sidebar, text=name, anchor="w", command=lambda char=char: select_character(char))
        char_button.grid(row=i // 3, column=i % 3, sticky="ew", padx=0, pady=0)

    for col in range(3):
        sidebar.grid_columnconfigure(col, weight=1)

# Select a character from the sidebar
def select_character(char: Character):
    global selected_character
    selected_character = char

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
    char = level_grid[row][col] or empty_character
    char_image = char_images.get(char.name, char_images[empty_character.name])

    button = level_buttons[row][col]
    button.config(image=char_image)
    button.image = char_image

# Create the grid for the level
def create_grid():
    for r in range(ROWS):
        for c in range(COLS):
            level_grid[r][c] = empty_character
            char_image = char_images.get(empty_character.name)
            btn = tk.Button(grid_frame, image=char_image, borderwidth=0, command=lambda r=r, c=c: place_character(r, c))
            btn.image = char_image
            btn.grid(row=r, column=c)
            level_buttons[r][c] = btn

# Export function, updated to use empty_character as needed
def export_screen_drawing():
    pass

# Export binary level data
def export_level_data():
    pass

# Export the grid data into file, that can be imported back in by the import_screen function
def export_screen():
    pass

# Import function, updated to initialize cells as empty_character when needed
def import_screen():
    pass

def populate_right_sidebar():
    for widget in sidebar2.winfo_children():
        widget.destroy()

    export_button_drawing = tk.Button(sidebar2, text="Export screen to draw", command=export_screen_drawing)
    export_button_data = tk.Button(sidebar2, text="Export screen for level data", command=export_level_data)
    export_button_screen = tk.Button(sidebar2, text="Export screen", command=export_screen)
    import_button = tk.Button(sidebar2, text="Import screen", command=import_screen)

    export_button_drawing.pack(fill=tk.X, padx=5, pady=5)
    export_button_data.pack(fill=tk.X, padx=5, pady=5)
    export_button_screen.pack(fill=tk.X, padx=5, pady=5)
    import_button.pack(fill=tk.X, padx=5, pady=5)

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

    populate_right_sidebar()

    print("🙏")
    root.mainloop()
