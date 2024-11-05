import serial
import time
data_size = 8
def send_number_8bits(serial_port, number, data_size):
    # Send the number in 8-bit chunks to the FPGA.
    if not (0 <= number < 65536):
        raise ValueError("number value must be between 0 and 65535.")
    
    for i in range(data_size//8):
        print(f"Number {number}")
        print(f"Byte{i}: {number}")
        serial_port.write(number.to_bytes(1, 'big'))
        number = number>>8
        time.sleep(0.1)

def send_number_16bits(serial_port, number, data_size):
    # Send the number in 8-bit chunks to the FPGA.
    if not (0 <= number < 65536):
        raise ValueError("number value must be between 0 and 65535.")
    
    byte1 = (number >> 8) & 0xFF
    byte2 = number & 0XFF

    serial_port.write(byte1.to_bytes(1, 'big'))
    serial_port.write(byte2.to_bytes(1, 'big'))

def send_number_32bits(serial_port, number, data_size):
    # Send the number in 8-bit chunks to the FPGA.
    if not (0 <= number < 65536):
        raise ValueError("number value must be between 0 and 65535.")
    
    byte1 = (number >> 24) & 0xFF
    byte2 = (number >> 16) & 0xFF
    byte3 = (number >> 8) & 0xFF
    byte4 = number & 0XFF

    serial_port.write(byte1.to_bytes(1, 'big'))
    serial_port.write(byte2.to_bytes(1, 'big'))
    serial_port.write(byte3.to_bytes(1, 'big'))
    serial_port.write(byte4.to_bytes(1, 'big'))
  
def send_number_64bits(serial_port, number, data_size):
    # Send the number in 8-bit chunks to the FPGA.
    if not (0 <= number < 65536):
        raise ValueError("number value must be between 0 and 65535.")
    
    byte1 = (number >> 56) & 0xFF
    byte2 = (number >> 48) & 0xFF
    byte3 = (number >> 40) & 0xFF  
    byte4 = (number >> 32) & 0xFF
    byte5 = (number >> 24) & 0xFF
    byte6 = (number >> 16) & 0xFF
    byte7 = (number >> 8) & 0xFF
    byte8 = number & 0XFF

    serial_port.write(byte1.to_bytes(1, 'big'))
    serial_port.write(byte2.to_bytes(1, 'big'))
    serial_port.write(byte3.to_bytes(1, 'big'))
    serial_port.write(byte4.to_bytes(1, 'big'))
    serial_port.write(byte5.to_bytes(1, 'big'))
    serial_port.write(byte6.to_bytes(1, 'big'))
    serial_port.write(byte7.to_bytes(1, 'big'))
    serial_port.write(byte8.to_bytes(1, 'big'))
  

def receive_number_8bits(serial_port, data_size):
    result = 0
    for i in range(2*data_size//8):
        byte = int.from_bytes(serial_port.read(1), 'big')
        print(f"Byte{i}: {byte}")
        result = (result << 8) | byte
    print(f"Result: {result}")
    return result

def receive_number_16bits(serial_port, data_size):
    result = 0
    
    for i in range(4):
        byte = int.from_bytes(serial_port.read(1), 'big')
        print(f"Byte{i}: {byte}")
        result = (result << 8) | byte
    print(f"Result: {result}")
    return result

def receive_number_32bits(serial_port, data_size):
    result = 0
    
    for i in range(8):
        byte = int.from_bytes(serial_port.read(1), 'big')
        print(f"Byte{i}: {byte}")
        result = (result << 8) | byte
    print(f"Result: {result}")
    return result

def receive_number_64bits(serial_port, data_size):
    result = 0
    
    for i in range(16):
        byte = int.from_bytes(serial_port.read(1), 'big')
        print(f"Byte{i}: {byte}")
        result = (result << 8) | byte
    print(f"Result: {result}")
    return result

def main():
    serial_port = serial.Serial(port='COM6', baudrate=9600, timeout=1)
   
    try:
        mat_A = [[2, 2, 2],
                 [2, 2, 2],
                 [2, 2, 2]]
        mat_B = [[2, 2, 2],
                 [2, 2, 2],
                 [2, 2, 2]]
        
        resMat = [[0, 0, 0],
                  [0, 0, 0],
                  [0, 0, 0]]
       
        # Send matrix A
        for row in mat_A:
            for element in row:
                print(f"Sending {element} from matrix A")
                send_number_8bits(serial_port, element, data_size)
   
        # Send matrix B
        for row in mat_B:
            for element in row:
                print(f"Sending {element} from matrix B")
                send_number_8bits(serial_port, element, data_size)
        print()
        print()
                          
        # Receive result matrix
        for i in range(3):
            for j in range(3):
                result = receive_number_8bits(serial_port, data_size)
                resMat[i][j] = result
                print(f"Received {result} for resMat[{i}][{j}]")
        print("Resultant Matrix:")
        for row in resMat:
            print(row)
    finally:
        serial_port.close()

if __name__ == "__main__":
    main()
