header_size = 2 # 001e

data = []

with open("title_screen_y.bin", "rb") as file:
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

with open("titlescreen-rle-encoded.bin", "wb") as file:
    file.write(encoded_data)
