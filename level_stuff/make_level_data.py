level_to_write = "level1.bin"
spot_for_level_to_write = "../src/levels/level1.bin"

def read_character_table(file_path):
    character_list = []

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line.endswith(':'):
                character_name = line[:-1]
                character_list.append(character_name)

    return character_list

def write_level_to_binary(level, characters, output_path):
    binary_data = bytearray()

    for item in level:
        if isinstance(item, tuple):
            character_name, coord_hex = item
            character_code = characters.index(character_name) - 1
            coord_value = int(coord_hex, 16)

            binary_data.append(character_code)
            binary_data.extend(coord_value.to_bytes(2, 'little'))
        elif isinstance(item, str) and item == "0xff":
            binary_data.append(0xff)

    with open(output_path, 'wb') as bin_file:
        bin_file.write(binary_data)
    print(f"Binary file written to {output_path}")

file_path = '../src/extras/character-table.s'
characters = read_character_table(file_path)

level = [("laser_receptor", "0x1e5b"), ("laser_shooter", "0x1f83"), "0xff"]

write_level_to_binary(level, characters, spot_for_level_to_write)
