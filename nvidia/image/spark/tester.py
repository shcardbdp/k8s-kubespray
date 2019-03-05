from tmp import AESCipher as ac

ac = ac.AESCipher(key="aaa1234")




pw = "password"




print("pw: {}".format(pw))
print("encrypt: {}".format(ac.encrypt(raw=pw)))
print("decrypt: {}".format(ac.decrypt(enc=ac.encrypt(raw=pw))))

