; Zero Page variable definitions

    seg.u ZP
    org $00
data_addr_low_z               ds.b 1      ; address of some data being loaded (low byte)
data_addr_high_z              ds.b 1      ; address of some data being loaded (high byte)
load_addr_low_z               ds.b 1      ; destination address (low byte)
load_addr_high_z              ds.b 1      ; destination address (high byte)
screen_mem_addr_coord_z       ds.b 2      ; screen memory address for a given (x, y) coordinate
current_byte_from_data_z      ds.b 1      ; current byte from the data being loaded (used in rle decoder)
count_z                       ds.b 1      ; count of the current byte from the data being loaded (used in rle decoder)
value_z                       ds.b 1      ; value of the current byte from the data being loaded (used in rle decoder)
what_level_tracker_z          ds.b 1      ; current level tracker
level_data_addr_low_z         ds.b 1      ; low byte of level data address
level_data_addr_high_z        ds.b 1      ; high byte of level data address
cursor_x_z                    ds.b 1      ; cursor X position
cursor_y_z                    ds.b 1      ; cursor Y position
curr_char_code_z              ds.b 1      ; current character code, used in level.s for reading in char codes from level data bin
TMP_X                       ds.b 1      ; temporary X coordinate
TMP_Y                       ds.b 1      ; temporary Y coordinate
TMP_CHAR_CODE               ds.b 1      ; temporary character code
x_y_to_screen_mem_output    ds.b 2      ; output of f_convert_xy_to_screen_mem_addr
    seg