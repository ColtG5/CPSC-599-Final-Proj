import os
from tkinter import filedialog

header_size = 2 # 001e
data = []

input_file = filedialog.askopenfilename(
    title=".bin file you want to rle encode", filetypes=[("Binary files", "*.bin")], initialdir=os.getcwd()
)

with open(input_file, "rb") as file:
    while byte := file.read(1):
        data.append(byte[0])


# header = data[:header_size]
header = [0x00, 0x1e] # 001e
print(header)
encoded_data = bytearray(header)

i = 0
while i < len(data):
    count = 1
    value = data[i]
    
    while (i + count < len(data)) and (data[i + count] == value) and (count < 255):
        count += 1
    
    encoded_data.extend([count, value])
    i += count
    
encoded_data.extend([0]) # count of 0 to signify end

input_file_name = os.path.basename(input_file)
output_file = f"{os.path.splitext(input_file_name)[0]}-rle-encoded.bin"

with open(output_file, "wb") as file:
    file.write(encoded_data)
