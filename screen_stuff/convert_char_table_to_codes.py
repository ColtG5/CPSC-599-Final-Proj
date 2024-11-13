import os
import tkinter as tk
from tkinter import filedialog


# Function to parse the input file and generate the updated labels with character codes
def generate_table_with_char_codes(input_file, output_file):
    try:
        with open(input_file, "r") as file:
            lines = file.readlines()

        modified_lines = []
        label_counter = 0
        for line in lines:
            if line.strip():  # dont wanna process empty lines below
                if not line.startswith("\t"): # give a code to every line that isnt blank space and isnt tabbed
                    # Construct a new label with the format `name_code = index`
                    label = line.split()[0]
                    modified_label = f"{label}_code = {label_counter}\n"
                    modified_lines.append(modified_label)
                    label_counter += 1
                else:
                    # Just add the line without modification
                    modified_lines.append(line)
            else:
                modified_lines.append(line)

        # Write the modified content to the output file
        with open(output_file, "w") as file:
            file.writelines(modified_lines)

        print(f"Table with character codes has been saved to {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")


# Function to open a file explorer to select the input file and output file
def select_files():
    root = tk.Tk()
    root.withdraw()

    # Prompt the user to select the input file
    input_file = filedialog.askopenfilename(
        title="Select a .s file", filetypes=[("Assembly files", "*.s")], initialdir=os.getcwd()
    )

    if not input_file:
        print("No input file selected.")
        return

    # Prompt the user to select the output file location
    output_file = filedialog.asksaveasfilename(
        title="Save the modified file as", defaultextension=".s", filetypes=[("Assembly files", "*.s")], initialdir=os.getcwd()
    )

    if not output_file:
        print("No output file selected.")
        return

    generate_table_with_char_codes(input_file, output_file)


if __name__ == "__main__":
    select_files()
