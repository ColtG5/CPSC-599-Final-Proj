from tkinter import *
from tkinter import messagebox, simpledialog

root = Tk()
root.title("VIC-20 Melody Creator")

# Notes list to store the melody and their delays
melody = []

# Function to add a note with delay to the melody
def add_note_with_delay(note, delay):
    melody.append((note, delay))
    listbox.insert(END, f"{note} ({delay})")

# Function to delete a selected note
def delete_note():
    selected = listbox.curselection()
    if selected:
        listbox.delete(selected)
        melody.pop(selected[0])

# Function to export melody to assembly code
def export_melody():
    melody_name = simpledialog.askstring("Melody Name", "Enter a name for the melody:")
    if not melody_name:
        return

    try:
        with open(f"{melody_name}.s", "w") as f:
            f.write(f"; VIC-20 melody: {melody_name}\n\n")
            f.write("    processor 6502\n")
            f.write("    org $1001\n\n")
            f.write('    include "stub.s"\n\n')
            f.write("; Set volume to maximum\n")
            f.write("    lda #15\n    sta $900E\n\n")
            
            f.write("play_melody:\n")
            
            for note, delay in melody:
                frequency, speaker = get_frequency_and_speaker(note)
                f.write(f"    ; Play note {note}\n")
                f.write(f"    lda #{frequency} ; Frequency for {note}\n")
                f.write(f"    sta {speaker} ; Play note on {speaker}\n")
                f.write(f"    jsr {delay}_delay\n")
                f.write(f"    lda #$00 ; Stop note\n    sta {speaker}\n\n")
            
            f.write("    jmp play_melody\n\n")

            # Write longer delay routines
            f.write("short_delay:\n    ldx #$FF\nshort_loop:\n    ldy #$FF\ninner_short_loop:\n    dey\n    bne inner_short_loop\n    dex\n    bne short_loop\n    rts\n\n")
            f.write("medium_delay:\n    ldx #$FF\nmedium_outer:\n    ldy #$FF\ninner_medium_loop:\n    dey\n    bne inner_medium_loop\n    dex\n    bne medium_outer\n    rts\n\n")
            f.write("long_delay:\n    ldx #$FF\nlong_outer:\n    ldy #$FF\ninner_long_loop:\n    dey\n    bne inner_long_loop\n    dex\n    bne long_outer\n    rts\n\n")
        
        messagebox.showinfo("Export Melody", f"Melody {melody_name} exported successfully!")

    except Exception as e:
        messagebox.showerror("Error", f"Failed to export melody: {str(e)}")

# Function to get frequency value and correct speaker for VIC-20 based on the note
def get_frequency_and_speaker(note):
    note_frequencies = {
        'C4': ('$A0', '$900A'), 'D4': ('$B0', '$900A'), 'E4': ('$C0', '$900A'),
        'F4': ('$90', '$900B'), 'G4': ('$D0', '$900B'), 'A4': ('$E0', '$900C'),
        'C5': ('$B0', '$900C'), 'E5': ('$C0', '$900C'), 'G5': ('$D0', '$900C')
    }
    return note_frequencies.get(note, ('$A0', '$900A'))  # Default to C4 if not found

# Create the main UI components
listbox = Listbox(root, width=40, height=10)
listbox.grid(columnspan=4, row=0, padx=10, pady=10)

# Note-delay combinations for lower octave (C4-A4)
note_delay_combos_lower = [
    ('C4', 'short'), ('C4', 'medium'), ('C4', 'long'),
    ('D4', 'short'), ('D4', 'medium'), ('D4', 'long'),
    ('E4', 'short'), ('E4', 'medium'), ('E4', 'long'),
    ('F4', 'short'), ('F4', 'medium'), ('F4', 'long'),
    ('G4', 'short'), ('G4', 'medium'), ('G4', 'long'),
    ('A4', 'short'), ('A4', 'medium'), ('A4', 'long')
]

# Note-delay combinations for higher octave (C5-G5)
note_delay_combos_higher = [
    ('C5', 'short'), ('C5', 'medium'), ('C5', 'long'),
    ('E5', 'short'), ('E5', 'medium'), ('E5', 'long'),
    ('G5', 'short'), ('G5', 'medium'), ('G5', 'long')
]

# Section for lower notes
#lower_note_label = Label(root, text="Lower Octave Notes (C4 - A4):", font=("Arial", 12, "bold"))
#lower_note_label.grid(columnspan=4, row=1, pady=(10, 0))

# Create buttons for each lower note-delay combination with proper grid alignment
for i, (note, delay) in enumerate(note_delay_combos_lower):
    btn = Button(root, text=f"{note} - {delay.capitalize()}", command=lambda n=note, d=delay: add_note_with_delay(n, d))
    btn.grid(column=i % 4, row=2 + i // 4, padx=5, pady=5)

# Section for higher notes
#higher_note_label = Label(root, text="Higher Octave Notes (C5, E5, G5):", font=("Arial", 12, "bold"))
#higher_note_label.grid(columnspan=4, row=4, pady=(10, 0))

# Create buttons for each higher note-delay combination with proper grid alignment
for i, (note, delay) in enumerate(note_delay_combos_higher):
    btn = Button(root, text=f"{note} - {delay.capitalize()}", command=lambda n=note, d=delay: add_note_with_delay(n, d))
    btn.grid(column=i % 4, row=5 + i // 4, padx=5, pady=5)

# Delete button
delete_button = Button(root, text="Delete Selected Note", command=delete_note)
delete_button.grid(columnspan=4, row=7, padx=5, pady=10)

# Export button
export_button = Button(root, text="Export to Assembly", command=export_melody)
export_button.grid(columnspan=4, row=8, padx=5, pady=10)

root.mainloop()
