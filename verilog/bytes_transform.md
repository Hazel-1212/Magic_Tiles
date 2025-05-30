# Memo

## module uart_with_debouncer

### FSM state machine

State	Description

IDLE	Waits for a new button press

SEND1	Sends note1

WAIT1	Waits for uart_send to fall & ready again

SEND2	Sends note2

## ASCII

- A-Z

| Char | Hex | Char | Hex |
|------|-----|------|-----|
| A    | 41  | N    | 4E  |
| B    | 42  | O    | 4F  |
| C    | 43  | P    | 50  |
| D    | 44  | Q    | 51  |
| E    | 45  | R    | 52  |
| F    | 46  | S    | 53  |
| G    | 47  | T    | 54  |
| H    | 48  | U    | 55  |
| I    | 49  | V    | 56  |
| J    | 4A  | W    | 57  |
| K    | 4B  | X    | 58  |
| L    | 4C  | Y    | 59  |
| M    | 4D  | Z    | 5A  |

- 0–9

| Char | Hex |
|------|-----|
| 1    | 31  | 
| 2    | 32  | 
| 3    | 33  | 
| 4    | 34  | 
| 5    | 35  | 
| 6    | 36  | 
| 7    | 37  | 
| 8    | 38  | 
| 9    | 39  | 
| 0    | 40  | 

- Other Useful Characters

| Char | Hex | Description         |
|------|-----|---------------------|
| ' '  | 20  | Space               |
| '\n' | 0A  | Line feed (LF)      |
| '\r' | 0D  | Carriage return     |
| '!'  | 21  | Exclamation         |
| '/'  | 2F  | Slash               |
| ':'  | 3A  | Colon               |
