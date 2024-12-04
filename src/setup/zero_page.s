; Zero Page variable definitions

    seg.u ZP
    org $00
data_addr_low_z                     ds.b 1      ; address of some data being loaded (low byte)
data_addr_high_z                    ds.b 1      ; address of some data being loaded (high byte)
load_addr_low_z                     ds.b 1      ; destination address (low byte)
load_addr_high_z                    ds.b 1      ; destination address (high byte)
screen_mem_addr_coord_z             ds.b 2      ; screen memory address for a given (x, y) coordinate
current_byte_from_data_z            ds.b 1      ; current byte from the data being loaded (used in rle decoder)
count_z                             ds.b 1      ; count of the current byte from the data being loaded (used in rle decoder)
value_z                             ds.b 1      ; value of the current byte from the data being loaded (used in rle decoder)
what_level_tracker_z                ds.b 1      ; current level tracker
level_data_addr_low_z               ds.b 1      ; low byte of level data address
level_data_addr_high_z              ds.b 1      ; high byte of level data address
level_data_tracker_z                ds.b 1      ; tracks our current offset in the level data
cursor_x_z                          ds.b 1      ; cursor X position
cursor_y_z                          ds.b 1      ; cursor Y position
last_cursor_x_z                     ds.b 1      ; last cursor X position
last_cursor_y_z                     ds.b 1      ; last cursor Y position
curr_char_pressed_z                 ds.b 1      ; current character pressed by player
curr_char_code_z                    ds.b 1      ; current character code, used in level.s for reading in char codes from level data bin
tmp_x_z                             ds.b 1      ; temporary X coordinate
tmp_y_z                             ds.b 1      ; temporary Y coordinate
tmp_char_code_z                     ds.b 1      ; temporary character code used in drawing level data
func_arg_1_z                        ds.b 1      ; function argument 1
func_arg_2_z                        ds.b 1      ; function argument 2
func_output_low_z                   ds.b 1      ; function output 1 (low byte)
func_output_high_z                  ds.b 1      ; function output 2 (high byte)
x_y_to_screen_mem_output_z          ds.b 2      ; output of f_convert_xy_to_screen_mem_addr
inventory_item_z                    ds.b 1      ; inventory item character code
covered_char_x_z                    ds.b 1      ; x coord of a char being covered by the cursor (if any)
covered_char_y_z                    ds.b 1      ; y coord of a char being covered by the cursor (if any)
covered_char_code_z                 ds.b 1      ; character code of a char being covered by the cursor (if any)
covered_laser_x_z                   ds.b 1      ; x coord of a laser being covered by the cursor (if any)
covered_laser_y_z                   ds.b 1      ; y coord of a laser being covered by the cursor (if any)
wall_collision_flag_z               ds.b 1      ; collision flag for debugging purposes
obj_collision_flag_z                ds.b 1      ; collision flag for debugging purposes
laser_collisiong_flag_z             ds.b 1      ; collision flag for debugging purposes
was_covering_char_z                 ds.b 1      ; flag for if the cursor was covering a char in its last position (we moved off of the covered char spot)
laser_head_x_z                      ds.b 1      ; x coord of the laser head
laser_head_y_z                      ds.b 1      ; y coord of the laser head
laser_direction_z                   ds.b 1      ; direction of the laser (1 = up, 2 = right, 3 = down, 4 = left)
num_of_receptors_in_level_z         ds.b 1      ; a constant total for each level for how many receptors there are in each level (used to reset receptors_hit_z each time we redraw the lasers)
receptors_hit_z                     ds.b 1      ; win condition for a level, number of receptors hit by laser (when this is equal to receptors_in_level, the level is won)

    seg