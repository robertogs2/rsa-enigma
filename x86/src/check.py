import math
testing = 3
bits = 256
#### Variables guardadas
prime1 = int(open('keys/prime' + str(bits) + '_1.bin', 'rb').read().hex(), 16)
prime2 = int(open('keys/prime' + str(bits) + '_2.bin', 'rb').read().hex(), 16)
keyn = int(open('keys/keyn.bin', 'rb').read().hex(), 16)
keye = int(open('keys/keye.bin', 'rb').read().hex(), 16)
keyd = int(open('keys/keyd.bin', 'rb').read().hex(), 16)
a = int(open('messages/msg.txt', 'rb').read().hex(), 16)
b = int(open('messages/msge.bin', 'rb').read().hex(), 16)
msgd = int(open('messages/msgd.txt', 'rb').read().hex(), 16)
keyn_test = prime1*prime2
keyl_test = (prime1-1)*(prime2-1)

def test_keys():
	good = True
	if(keyn != keyn_test): #Chequeo multiplicacion correcta
		print ('N does not match')
		good = False
	if(math.gcd(keye, keyl_test)!=1): #Chequeo coprimalidad E con L
		good = False
		print ("E is not coprime with L")
	if ((keyd*keye)%keyl_test != 1): #de%l=1
		good = False
		print ("Inverse is not correct")
	if(good):
		print("Keys are correct with RSA")
	return

def test_encryption():
	b_test = pow(a, keye, keyn) #Encripta a con las llaves
	print('Encrypted message using Python:\n' + str(hex(b_test))+ '\n') 	#Imprime mensaje encriptado por Python
	print('Encypted message using x86:\n' + str(hex(b))+'\n') 		#Imprime mensaje encriptado por ensamblador
	if(b != b_test):
		print("Wrong encryption")
	else:
		print("Encryption was succesfull")
	return

def test_decryption():
	a_test = pow(b, keyd, keyn) #Desencripta b con las llaves
	print('Decrypted message in hexadecimal using Python:\n' + str(hex(a_test))+'\n') 	#Imprime mensaje desencriptado por Python
	print('Decrypted message in hexadecimal using x86:\n' + str(hex(msgd))+'\n') 		#Imprime mensaje desencriptado por ensamblador
	print('Original message in hexadecimal:\n' + hex(a)+'\n')							#Imprime mensaje original
	if(a != a_test):
		print("Wrong decryption using python")
	elif(msgd != a_test):
		print("Wrong decryption by assembly")
	else:
		print("Decryption was succesfull")
	return

if(testing == 0): #Test de llaves
	test_keys()
elif(testing == 1): #Test de encriptacion
	test_encryption()
elif(testing == 2): #Test de desencripcion
	test_decryption()
else:	#Test de todo
	test_keys()
	test_encryption()
	test_decryption()