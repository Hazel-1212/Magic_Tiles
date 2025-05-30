from ctypes import *
import time
import sys
import uart
# Load DWF library (WaveForms)
if sys.platform.startswith("win"):
    dwf = cdll.LoadLibrary("dwf.dll")
elif sys.platform.startswith("darwin"):
    dwf = cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")
else:
    dwf = cdll.LoadLibrary("libdwf.so")
# Open device
hdwf = c_int()

print("Opening first device...")
dwf.FDwfDeviceOpen(c_int(-1), byref(hdwf))
if hdwf.value == 0:
    print("Failed to open device AD2")
    szerr = create_string_buffer(512)
    dwf.FDwfGetLastErrorMsg(szerr)
    print(str(szerr.value))
    quit()
dwf.FDwfDigitalIOOutputEnableSet(hdwf, c_int(0))  # disable outputs

def uart_init(pin):
    """Initialize"""
    # Configure UART: 9600-8N1
    dwf.FDwfDigitalUartRateSet(hdwf, c_double(9600))
    dwf.FDwfDigitalUartTxSet(hdwf, c_int(13))  # TX: DIO-13 -> Not used
    dwf.FDwfDigitalUartRxSet(hdwf, c_int(pin))  # RX: DIO-pin : pin=0 -> left pin=1 -> right
    dwf.FDwfDigitalUartBitsSet(hdwf, c_int(8))
    dwf.FDwfDigitalUartParitySet(hdwf, c_int(0))  # No parity
    dwf.FDwfDigitalUartStopSet(hdwf, c_double(1))  # 1 stop bit

    # Initialize TX and RX
    dwf.FDwfDigitalUartTx(hdwf, None, c_int(0))  # Idle TX
    dwf.FDwfDigitalUartRx(hdwf, None, c_int(0), byref(c_int()), byref(c_int()))  # Enable RX

def receive_notes(ser,pin,req): # pin:dio[0]or dio[1] req:'R'or"r"
    """receive the notes"""
    uart_init(pin)
    # === Send 'R' or 'r' to FPGA ===
    uart.send_data(ser, req)  # Send 'R' to FPGA

    # === Receive FPGA's response ===
    rgRX = create_string_buffer(200)  # Buffer size
    cRX = c_int()
    fParity = c_int()
    received_data = []

    timeout = time.perf_counter() + 1  # Read 1 second
    while time.perf_counter() < timeout:
        dwf.FDwfDigitalUartRx(hdwf, rgRX, c_int(sizeof(rgRX) - 1), byref(cRX), byref(fParity))

        if cRX.value > 0:
        # Extract only the valid part of the buffer
            bytes_read = rgRX.raw[:cRX.value]
            #print(bytes_read)
            try:
                decoded = bytes_read.decode('ascii')
                received_data.extend(decoded)
            except UnicodeDecodeError:
                print("Undecodable bytes received")

        if fParity.value != 0:
            print("Parity error")

    notes_raw=''.join(received_data)
    length = []
    notes = []
    for char in notes_raw:
        dec_value = translate_char_to_dec(char)
        if  ord('Z') >= ord(char) >= ord('A') or  ord('z') >= ord(char) >= ord('a'):
            notes.append(dec_value)
        else:
            length.append(dec_value)
    
    #dwf.FDwfDeviceCloseAll()
    return notes,length


def translate_char_to_dec(char):
    """Translate a character to its decimal representation."""
    #to decimal
    if 'A' <= char <= 'Z':
        return ord(char) - ord('A')  # A=10, B=11, ..., Z=25
    elif '0' <= char <= '9':
        return ord(char) - ord('0')  # 0=0, 1=1, ..., 9=9
    elif 'a' <= char <= 'z':
        return ord(char) - ord('a') 

def rail():
    """Decode the output from module lfsr"""
    try:
        while True:
            #time.sleep(0.05)
            dwf.FDwfDigitalIOStatus(hdwf)
            value = c_int()
            dwf.FDwfDigitalIOInputStatus(hdwf, byref(value))

            dio14_level = (value.value >> 14) & 1
            dio15_level = (value.value >> 15) & 1
            return dio14_level*2+dio15_level
    except KeyboardInterrupt:
        print("Stopped.")
        dwf.FDwfDeviceCloseAll()