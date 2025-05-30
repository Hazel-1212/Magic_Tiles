import serial
import time

def open_serial_port():
    """
    Opens the serial port with the specified parameters.
    """
    COM_PORT = 'COM3'
    BAUD_RATES = 9600
    try:
        ser = serial.Serial(
            port=COM_PORT,
            baudrate=BAUD_RATES,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=1
        )
        print(f'Opened serial port {ser.name} successfully!')
        return ser
    except serial.SerialException as e:
        print(f'Error opening serial port: {e}')
        return None
    
def send_data(ser, data):
    """
    Sends data to the serial port.
    """
    try:
        ser.write(data.encode('utf-8'))  # Send data as bytes
        
    except serial.SerialException as e:
        print(f'Error sending data: {e}')
        
def receive_data(ser):
    """
    Receives data from the serial port.
    """
    try:
        while ser.in_waiting:
            data_raw = ser.read(ser.in_waiting)  # Read all available data
            #data = int.from_bytes(data_raw, "big")
            message = data_raw.decode('utf-8', 'ignore')
            return message.strip()
        return None
            
    except serial.SerialException as e:
        print(f'Error receiving data: {e}')