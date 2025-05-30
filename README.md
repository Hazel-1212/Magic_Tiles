# Magic_Tiles
This final project is an FPGA music game inspired by Magic Tiles. 

We modified the single-player gameplay into a two-player mode, 

where one player handles the main melody and the other plays the accompaniment. 

Each tile now corresponds to a specific number on the keypad.

The core of the project lies in enabling communication between the FPGA and Python through bidirectional UART serial ports. 

The goal is to allow the user to visualize the game using their own laptop. 

The UART connection can come either from the built-in ports on the development board or from the AD2 (Analog Discovery 2) pins.
