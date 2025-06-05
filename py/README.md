# Python : Magic Tiles 

## Files

### main.py
Run this file. Dominate all files.

### game.py
Implement the pygame rendering function and spawn the tiles.

### oop_tiles.py
Use **class tile()** to manage the tiles.

### uart.py
**Communicate with Nexys4 DDR.**

### notes_rx.py
**Communicate with Analog Discovery 2.**

- WavwForms downloaded is needed.

- Explore more about managing AD2 with C++/Python in (maybe) the folder 

**"C:\Program Files (x86)\Digilent\WaveFormsSDK\samples"** (or C:\Program Files\Digilent in some case)

There are some sample code written in C++ and Python. 

They are downloaded together with WaveForms APP.

- This part may differ depending on where the compter save the library (*The path may differ*), 
so check **samples** folder first.

    #Load DWF library

    if sys.platform.startswith("win"):

        dwf = cdll.LoadLibrary("dwf.dll") 

    elif sys.platform.startswith("darwin"):

        dwf = cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")

    else:
    
        dwf = cdll.LoadLibrary("libdwf.so")

## Functions
### Connect with FPGA

- **uart.py** is used to interact with FPGA.

- We first check device manager to know the port name “COM3” and set the baud rate as 9600 (the same as we design in Verilog). 

### Connect with AD2

Thankfully, WaveForms SDK has provided sample code for downloader to manage AD2 with Python/C++.

- **note_rx.py** is used to interact with AD2.

- The main function of AD2 UART is to receive notes when the game starts.

- Another function of AD2 is to detect the random rail number from **module lfsr**. 
The random rail code is obtained by detecting the high/low level of
the DIO[14] and DIO[15] when the new tile is spawned.