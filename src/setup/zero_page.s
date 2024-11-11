; Zero Page variable definitions

    seg.u ZP
    org $00
DATA_ADDR_LOW               ds.b 1      ; address of some data being loaded (low byte)
DATA_ADDR_HIGH              ds.b 1      ; address of some data being loaded (high byte)
LOAD_ADDR_LOW               ds.b 1      ; destination address (low byte)
LOAD_ADDR_HIGH              ds.b 1      ; destination address (high byte)
current_byte_from_data      ds.b 1      ; current byte from the data being loaded (used in rle decoder)
count                       ds.b 1      ; count of the current byte from the data being loaded (used in rle decoder)
value                       ds.b 1      ; value of the current byte from the data being loaded (used in rle decoder)
what_level_tracker          ds.b 1      ; current level tracker
level_data_addr_low         ds.b 1      ; low byte of level data address
level_data_addr_high        ds.b 1      ; high byte of level data address
cursor_x                    ds.b 1      ; cursor X position
cursor_y                    ds.b 1      ; cursor Y position
portal_x                    ds.b 1      ; portal X position
portal_y                    ds.b 1      ; portal Y position
portal_placed               ds.b 1      ; 1 if portal is placed, 0 if not
previous_cursor_x           ds.b 1      ; previous cursor X position
previous_cursor_y           ds.b 1      ; previous cursor Y position
blank_tile                  ds.b 1      ; blank tile for erasing
curr_char_code              ds.b 1      ; current character code
    seg