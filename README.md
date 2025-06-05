# Magic_Tiles

## Intro
<img src="https://github.com/Hazel-1212/Magic_Tiles/blob/main/pictures/motivation.png" width=800>

**This final project is an FPGA music game inspired by Magic Tiles.**

We modified the single-player gameplay into a two-player mode, where one player handles the main melody and the other plays the accompaniment. 

Tiles with a number fall from the top of the screen on laptop along a rail, 
and players use keypad to input the number of the falling tiles, while the switch allows song selection.

Two sets of 7-segment displays show individual player scores. 

When either player reaches 60 points, Python interface is automatically closed, and LED color indicates the winner.

The system uses bidirectional UART communication, either via the FPGA board’s built-in serial port or through AD2 pins.

## Features
1. Bidirectional UART communication ensures real-time data synchronization.
2. Python uses Pygame to render the game interface and handle user interactions.
3. Supports independent control for both hands and tracks individual scores.
4. Displays game scores individually.

## Materials and Environment
- Nexys4 DDR
- Analog Discovery 2
- Speaker *2
- Keypad *2
- Pygame installed
- WaveForms installed
 (Make sure the folder is available **"C:\Program Files (x86)\Digilent\WaveFormsSDK\samples"**)

<img src="https://github.com/Hazel-1212/Magic_Tiles/blob/main/pictures/block.png" width=600>

## Modules

<img src="https://github.com/Hazel-1212/Magic_Tiles/blob/main/pictures/modules.png" width=800>

## Signal Flow in the Game Loop

This table describes how signals flow between the PC (Personal Computer) and FPGA during different phases of the rhythm game.

| Time          | Direction   | Function                                      |
|---------------|-------------|-----------------------------------------------|
| Game start    | PC → FPGA   | Request for notation                          |
| After request | FPGA → PC   | Transfer info about notes                     |
| During Game   | FPGA → PC   | Send user input (FPGA buttons or keyboard)    |
| During Game   | PC → FPGA   | Feedback on the correctness of the notes      |
| Game end      | FPGA → PC   | Close the game                                |