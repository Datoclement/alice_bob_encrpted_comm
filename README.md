A Simple Demonstration of Encrypted Communication (Alice and Bob)

Alice sends c1.txt (encrpted message), c2.txt (encrpted key) and c3.txt (signed hashed key).

Bob decodes c2.txt for the key, with which he decodes c1.txt for the message. To guarantee the source (it is well Alice who sends this message), c3.txt is decrpted and then compared to the hashed key.
