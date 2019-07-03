name = str(input("Inserte el nombre del archivo:\n"))
byte_add = int(input("Inserte la cantidad de Bytes a agregar al inicio:\n"))

f = open(name + ".txt")
raw_hex_file = f.read()
raw_hex_string = str(raw_hex_file)
raw_hex_string = 2*byte_add*"0"+raw_hex_string
byte_array = bytearray.fromhex(raw_hex_string)

f2 = open(name + ".bin", "wb")
f2.write(byte_array)
f2.close()
