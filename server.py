import serial
import time

def send_byte(serial_port, byte):
    serial_port.write(bytes([byte]))
    time.sleep(0.1)  # Short delay to ensure proper transmission

def read_byte(serial_port):
    while serial_port.in_waiting == 0:
        time.sleep(0.01)  # Wait for data
    return ord(serial_port.read(1))

def main():
    serial_port_name = 'COM6'
    matrix = []
    
    with serial.Serial(serial_port_name, 9600, timeout=1) as ser:
        print("Opened serial port: ", serial_port_name)

        # Send all 9 matrix elements
        for value in [1,1,1,1,1,1,1,5,6]:
            send_byte(ser, value)
        
        print("Sent all matrix elements")

        # Read the received matrix elements
        for _ in range(1):
            result = read_byte(ser)
            print(result)
            matrix.append(result)

        print("Received matrix:", matrix)

if __name__ == "__main__":
    main()
