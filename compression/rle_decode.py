header_size = 2  # 001e

encoded_data = []
with open("titlescreen-rle-encoded.bin", "rb") as file:
    while byte := file.read(1):
        encoded_data.append(byte[0])

header = encoded_data[:header_size]
decoded_data = bytearray(header)

i = header_size
while i < len(encoded_data) - 1: # skip last byte of 0 (thats for asm code where we cant do len() ! ! ! ! !)
    count = encoded_data[i]
    value = encoded_data[i + 1]
    
    decoded_data.extend([value] * count)
    i += 2

print(decoded_data)
