"""create_custom_chars.py

A tool that lets us create custom characters by selecting what pixels are on/off. It outputs characters 
into a '''''database''''' that stores some custom characters, that can then be copy pasted into the games 
character table (better method in the future).
"""

from tkinter import *
from tkinter import simpledialog, messagebox

char_database = "./custom_char_charsets/custom_chars.txt"

root = Tk()
root.title("vic-20 char creator")

button_states = [[0 for _ in range(8)] for _ in range(8)]
buttons = []


def clicked(btn, row, col):
    if button_states[row][col] == 0:
        btn.config(bg="black")
        button_states[row][col] = 1
    else:
        btn.config(bg="white")
        button_states[row][col] = 0


def export_character():
    char_name = simpledialog.askstring("Character Name", "Name for the character?")

    if char_name:
        try:
            with open(char_database, "r") as f:
                lines = f.readlines()

            char_start_idx = None
            char_end_idx = None

            for i, line in enumerate(lines):
                if line.strip() == char_name:
                    char_start_idx = i
                elif char_start_idx is not None and line.strip() == "":
                    char_end_idx = i
                    break

            char_data_lines = [f"\tdc.b %" + "".join(str(x) for x in row) + "\n" for row in button_states]

            if char_start_idx is not None:
                lines[char_start_idx:char_end_idx] = [f"{char_name}\n"] + char_data_lines + ["\n"]
            else:
                lines.append(f"{char_name}\n")
                lines.extend(char_data_lines)
                lines.append("\n")

            with open(char_database, "w") as f:
                f.writelines(lines)

            messagebox.showinfo("Export Character", f"Character {char_name} saved successfully!")

        except FileNotFoundError:
            with open(char_database, "w") as f:
                f.write(f"{char_name}\n")
                for row in button_states:
                    f.write("\tdc.b %" + "".join(str(x) for x in row) + "\n")
                f.write("\n")

            messagebox.showinfo("Export Character", f"Character {char_name} created and saved successfully!")


def import_character():
    char_name = simpledialog.askstring("Import Character", "Name of the character to import?")
    if not char_name:
        return
    char_name = char_name.lower()

    try:
        with open(char_database, "r") as f:
            lines = f.readlines()

            found = False
            for i, line in enumerate(lines):
                if line.strip().lower() == char_name:
                    found = True
                    for row in range(8):
                        binary_string = lines[i + 1 + row].strip().split("%")[-1]
                        for col in range(8):
                            button_states[row][col] = int(binary_string[col])
                            color = "black" if button_states[row][col] == 1 else "white"
                            buttons[row][col].config(bg=color)
                    break
            if not found:
                messagebox.showerror("Error", "Character not found!")
    except FileNotFoundError:
        messagebox.showerror("Error", "No character file found!")
        
def clear_grid():
    for row in range(8):
        for col in range(8):
            button_states[row][col] = 0
            buttons[row][col].config(bg="white")


for row in range(8):
    button_row = []
    for col in range(8):
        btn = Button(root, width=2, height=1, bg="white")
        btn.config(command=lambda b=btn, r=row, c=col: clicked(b, r, c))
        btn.grid(column=col, row=row)
        button_row.append(btn)
    buttons.append(button_row)

export_button = Button(root, text="Export As asm Code", command=export_character)
export_button.grid(columnspan=8, row=9)

import_button = Button(root, text="Import Character", command=import_character)
import_button.grid(columnspan=8, row=10)

clear_button = Button(root, text="Clear", command=clear_grid)
clear_button.grid(columnspan=8, row=11)

root.mainloop()
