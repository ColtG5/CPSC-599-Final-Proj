# level_checking.py

import sys

def read_level_data(file_path):
    try:
        with open(file_path, 'rb') as f:
            binary_data = f.read()
        
        # Each entry in the binary file is 3 bytes:
        # item code (1 byte), screen address low byte (1 byte), screen address high byte (1 byte)
        entries = []
        for i in range(0, len(binary_data), 3):
            if i + 2 >= len(binary_data):
                print("Warning: Incomplete entry at the end of file.")
                break
            
            item_code = binary_data[i]
            low_byte = binary_data[i + 1]
            high_byte = binary_data[i + 2]
            # Calculate the full 16-bit screen address
            screen_address = (high_byte << 8) | low_byte
            entries.append((item_code, screen_address))
        
        # Print each entry for verification
        print("Item Code | Screen Address")
        print("-------------------------")
        for item_code, screen_address in entries:
            print(f"{item_code:02X}       | ${screen_address:04X}")
        
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python level_checking.py <binary_file_path>")
    else:
        file_path = sys.argv[1]
        read_level_data(file_path)
