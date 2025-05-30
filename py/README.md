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

## Specification

### uart.send(ser)
1. Initial
- 'R' : Request the song code
2. Press Correct Note
- Left : 'C'
- Right: 'c' *lowercase*
- Score add 1

### uart.receive_data(ser)
1. A ~ L and O : Left Note 1 - 12 and None pressed
2. a ~ l and o : Right Note pressed
3. R : End the game

