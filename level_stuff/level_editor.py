import tkinter as tk
from tkinter import simpledialog, messagebox
import os
from PIL import Image

root = tk.Tk()
root.title("vic-20 level editor")

char_file = "custom_chars_title_screen.txt"
ROWS = 23
COLS = 22
CHAR_IMG_SIZE = 8
ZOOM_FACTOR = 4

OFFSET_FOR_CHARS_IN_TABLE = 0
ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE = "$10"


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
    try:
        os.makedirs("./char_images", exist_ok=True)
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

            # make an empty character
            characters["0_Empty"] = Character("0_Empty", [[0] * 8 for _ in range(8)])
            create_and_store_image(characters["0_Empty"])

        update_sidebar()

    except FileNotFoundError:
        messagebox.showerror("Error", f"No {char_file} found!")


# Create PNG and load the zoomed image for each character
def create_and_store_image(char: Character):
    img_size = (CHAR_IMG_SIZE, CHAR_IMG_SIZE)
    img = Image.new("RGB", img_size, color="white")
    pixels = img.load()

    # Convert binary data to black and white pixels
    for y, row in enumerate(char.data):
        for x, bit in enumerate(row):
            pixels[x, y] = (0, 0, 0) if bit == 1 else (255, 255, 255)

    filename = f"./char_images/{char.name}.png"
    img.save(filename)

    # Create a Tkinter image, pre-zoomed
    tk_image = tk.PhotoImage(file=filename).zoom(ZOOM_FACTOR)
    char_images[char.name] = tk_image


# Update the sidebar with character buttons
def update_sidebar():
    for widget in sidebar.winfo_children():
        widget.destroy()

    sorted_chars = sorted(characters.keys())
    gang = 0

    for name in sorted_chars:
        char = characters[name]
        char_button = tk.Button(sidebar, text=name, anchor="w", command=lambda char=char: select_character(char))
        char_button.grid(row=gang // 3, column=gang % 3, sticky="ew", padx=0, pady=0)
        gang += 1

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


def export_level_old():
    level_name = simpledialog.askstring("Export Level", "Name for the level? (will overwrite existing files!)")
    if level_name:
        with open(f"./levels/{level_name}.txt", "w") as f:

            f.write("level_char_table:\n")

            # dict storing name of each character used in level, as well as: what spot they are in character table + what coords require that character
            # characters_used_in_level: dict[str, tuple[int, list[tuple[int, int]]]] = dict()
            characters_used_in_level: dict[Character, list[tuple[int, int]]] = dict()
            for row_num, row in enumerate(level_grid):
                # print(row)
                for col, char in enumerate(row):
                    if isinstance(char, Character):
                        char: Character
                        if char.name == "0_Empty":
                            continue

                        if char not in characters_used_in_level.keys():
                            characters_used_in_level[char] = [(row_num, col)]
                        else:
                            characters_used_in_level[char].append((row_num, col))

            # print(characters_used_in_level)

            # write binary data for each character to create char table
            for char in characters_used_in_level.keys():
                f.write(f"{char.name}:\n")
                for row in char.data:
                    f.write("\tdc.b %" + "".join(str(x) for x in row) + "\n")
                f.write("\n")

            # print(list(characters_used_in_level.keys()))

            # asm code that will actually display the level
            f.write("level_drawing_code:\n")
            # for ewach char wer need to draw
            for char in characters_used_in_level.keys():
                # this works right!!!!!!?????????!!!!!
                num_in_table = list(characters_used_in_level.keys()).index(char)
                f.write(f"\n{char.name}_{num_in_table}:\n")
                f.write(f"\tlda #{num_in_table + OFFSET_FOR_CHARS_IN_TABLE}\n")
                f.write(f"\tsta {ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE}\n")

                # and for each spot on screen that needs that char, move the cursor there and CHROUT it
                for row, col in characters_used_in_level[char]:
                    f.write(
                        f"""
    ldx #{row}
    ldy #{col}
    jsr PLOT
    lda {ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE}
    jsr CHROUT
                            """
                    )

        messagebox.showinfo("Export Level", f"Level {level_name} exported successfully!")


def export_level():
    level_name = simpledialog.askstring("Export Level", "Name for the level? (will overwrite existing files!)")
    if level_name:
        with open(f"./levels/{level_name}.txt", "w") as f:

            f.write("level_char_table:\n")

            characters_used_in_level: dict[Character, list[tuple[int, int]]] = dict()
            for row_num, row in enumerate(level_grid):
                for col, char in enumerate(row):
                    if isinstance(char, Character):
                        char: Character
                        if char.name == "0_Empty":
                            continue

                        if char not in characters_used_in_level.keys():
                            characters_used_in_level[char] = [(row_num, col)]
                        else:
                            characters_used_in_level[char].append((row_num, col))

            # Write binary data for each character to create the char table
            # characters_used_in_level[characters["0_Empty"]] = []  # Ensure empty character is included
            for char in characters_used_in_level.keys():
                f.write(f"{char.name}:\n")
                for row in char.data:
                    f.write("\tdc.b %" + "".join(str(x) for x in row) + "\n")
                f.write("\n")

            # Assembly code for displaying the level
            f.write("level_drawing_code:\n")

            for char in characters_used_in_level.keys():
                # if char.name == "0_Empty":
                #     continue
                num_in_table = list(characters_used_in_level.keys()).index(char)
                f.write(f"\n{char.name}_{num_in_table}:\n")
                f.write(f"\tlda #{num_in_table + OFFSET_FOR_CHARS_IN_TABLE}\n")
                f.write(f"\tsta {ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE}\n")

                for row, col in characters_used_in_level[char]:
                    spot_in_screen_mem = (row * COLS) + col

                    # Adjust memory address dynamically based on character index
                    if spot_in_screen_mem < 0x100:
                        base_address = "1e"
                    else:
                        base_address = "1f"  # Switch to 1d for memory beyond 1eff
                        spot_in_screen_mem -= 0x100

                    # Convert the spot_in_screen_mem to hex (2-digit format)
                    spot_in_screen_mem_hex = f"{spot_in_screen_mem:02x}"

                    f.write(
                        f"""
    lda {ZERO_PAGE_LOC_FOR_CHARS_FROM_TABLE}
    sta ${base_address}{spot_in_screen_mem_hex}
                            """
                    )

        messagebox.showinfo("Export Level", f"Level {level_name} exported successfully!")


def import_level_old():
    level_name = simpledialog.askstring("Import Level", "Name of the level to import?")
    if level_name:
        try:
            with open(f"./levels/{level_name}.txt", "r") as f:

                create_grid()

                # read for level_char_table: at top of file
                line = f.readline()
                if not line.strip() == "level_char_table:":
                    messagebox.showerror("Error", "Invalid level file!")
                    return

                while True:
                    line = f.readline()
                    if line.strip() == "level_drawing_code:":
                        break

                current_char: Character = None
                coord_x = -1
                coord_y = -1

                # keep reading lines until we get a char, x, and y, then put that into level grid, reset coords, go again, until all of that char are done, then reset char, then go AGAIN
                for line in f.readlines():
                    line = line.strip()

                    if line == "":
                        continue

                    if current_char is not None and coord_x != -1 and coord_y != -1:
                        level_grid[coord_x][coord_y] = current_char
                        update_grid_cell(coord_x, coord_y)
                        coord_x = -1
                        coord_y = -1
                        continue

                    if line.endswith(":"):
                        while not line.endswith("_"):
                            line = line[:-1]
                        char_name = line[:-1]
                        # print(char_name)
                        # print(characters.keys())
                        current_char = characters[char_name]
                        # print(current_char.data)
                        continue

                    if line.startswith("ldx #"):
                        coord_x = int(line.split("#")[-1])
                        # print(coord_x)
                        continue

                    if line.startswith("ldy #"):
                        coord_y = int(line.split("#")[-1])
                        # print(f"cur_char: {current_char}, x: {coord_x}, y: {coord_y}")
                        continue

        except FileNotFoundError:
            messagebox.showerror("Error", "Level not found!")


def import_level():
    level_name = simpledialog.askstring("Import Level", "Name of the level to import?")
    if level_name:
        try:
            with open(f"./levels/{level_name}.txt", "r") as f:
                create_grid()

                line = f.readline()
                if line.strip() != "level_char_table:":
                    messagebox.showerror("Error", "Invalid level file!")
                    return
                
                while True:
                    line = f.readline()
                    if line.strip() == "level_drawing_code:":
                        break

                current_char: Character = None
                coord_x = -1
                coord_y = -1

                for line in f.readlines():
                    line = line.strip()
                    # print(f"\tLine: {line}")
                    if line == "":
                        continue

                    # Ensure we have a character to place
                    # if current_char is not None and coord_x != -1 and coord_y != -1:
                    #     level_grid[coord_x][coord_y] = current_char
                    #     update_grid_cell(coord_x, coord_y)
                    #     coord_x = -1
                    #     coord_y = -1
                    #     print(f"Placed {current_char} at {coord_x}, {coord_y}")
                    #     continue
                    
                    if line.endswith(":"):
                        while not line.endswith("_"):
                            line = line[:-1]
                        char_name = line[:-1]
                        # print(char_name)
                        # print(characters.keys())
                        current_char = characters[char_name]
                        # print(current_char.data)
                        # print(f"New current char: {current_char}")
                        continue

                    # Handle the memory address lines to extract coordinates
                    if line.startswith("sta $1e") or line.startswith("sta $1f"):
                        screen_mem_address = int(line.split("$")[-1], 16)

                        # Calculate the effective address offset from 1e00
                        effective_address = screen_mem_address - 0x1E00

                        # Calculate the Y coordinate and X coordinate
                        coord_x = effective_address // COLS
                        coord_y = effective_address % COLS

                        # Make sure current_char is set before placing
                        # print(f"Address: {screen_mem_address:#04x}, char: {current_char}, x: {coord_x}, y: {coord_y}")
                        
                        level_grid[coord_x][coord_y] = current_char
                        update_grid_cell(coord_x, coord_y)
                        # print(f"Placed {current_char} at {coord_x}, {coord_y}")
                        coord_x = -1
                        coord_y = -1
                        continue

        except FileNotFoundError:
            messagebox.showerror("Error", "Level not found!")


def populate_right_sidebar():
    for widget in sidebar2.winfo_children():
        widget.destroy()

    export_button = tk.Button(sidebar2, text="Export level", command=export_level)
    import_button = tk.Button(sidebar2, text="Import level", command=import_level)
    import_old_button = tk.Button(sidebar2, text="Import level (old)", command=import_level_old)

    export_button.pack(fill=tk.X, padx=5, pady=5)
    import_button.pack(fill=tk.X, padx=5, pady=5)
    import_old_button.pack(fill=tk.X, padx=5, pady=5)


if __name__ == "__main__":
    sidebar = tk.Frame(root, bg="lightgrey")
    sidebar.grid(row=0, column=0, rowspan=ROWS, sticky="ns")
    # sidebar.grid_propagate(False)

    grid_frame = tk.Frame(root, width=2000, height=1150)
    grid_frame.grid(row=0, column=1, padx=5, pady=5)

    sidebar2 = tk.Frame(root, width=100, height=600, bg="lightgrey")
    sidebar2.grid(row=0, column=2, rowspan=ROWS, sticky="ns")
    sidebar2.grid_propagate(False)

    # Load characters, create PNGs, and load images into mem
    load_and_create_character_images()

    # Create the grid for placing characters
    create_grid()

    # populate right sidebar
    populate_right_sidebar()

    print("🙏")
    root.mainloop()
