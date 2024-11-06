spot_for_level_1_to_write = "../src/levels/level1.bin"
spot_for_level_2_to_write = "../src/levels/level2.bin"
spot_for_level_3_to_write = "../src/levels/level3.bin"


def read_character_table(file_path):
    character_list = []

    with open(file_path, "r") as file:
        for line in file:
            line = line.strip()
            if line.endswith(":"):
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
            binary_data.extend(coord_value.to_bytes(2, "little"))
        elif isinstance(item, str) and item == "0xff":
            binary_data.append(0xFF)

    with open(output_path, "wb") as bin_file:
        bin_file.write(binary_data)
    print(f"Binary file written to {output_path}")


file_path = "../src/extras/character-table.s"
characters = read_character_table(file_path)

level1 = [("laser_receptor", "0x1e60"), ("laser_shooter", "0x1f83"), "0xff"]
level2 = [
    ("laser_receptor", "0x1e5d"),
    ("laser_receptor", "0x1e68"),
    ("laser_shooter", "0x1f80"),
    ("laser_shooter", "0x1f82"),
    ("reflector_1", "0x1f20"),
    ("reflector_2", "0x1f00"),
    "0xff",
]
level3 = [
    ("laser_receptor", "0x1e5b"),
    ("laser_receptor", "0x1e6a"),
    ("laser_shooter", "0x1f80"),
    ("laser_shooter", "0x1f82"),
    ("reflector_1", "0x1f20"),
    ("reflector_2", "0x1f00"),
    ("portal", "0x1eca"),
    ("portal", "0x1f05"),
    ("wall", "0x1f54"),
    ("wall", "0x1f55"),
    ("wall", "0x1f56"),
    ("wall", "0x1f3e"),
    ("wall", "0x1f3f"),
    ("wall", "0x1f40"),
    "0xff",
]

write_level_to_binary(level1, characters, spot_for_level_1_to_write)
write_level_to_binary(level2, characters, spot_for_level_2_to_write)
write_level_to_binary(level3, characters, spot_for_level_3_to_write)
