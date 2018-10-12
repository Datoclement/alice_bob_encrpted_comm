clear
clear

# generate private keys and public keys
echo "Generating private keys and public keys..."
openssl genrsa -out alice/privateA
openssl rsa -in alice/privateA -pubout -out alice/publicA
openssl genrsa -out bob/privateB
openssl rsa -in bob/privateB -pubout -out bob/publicB
echo

# send public keys to each other
echo "Sending public keys to each other..."
cp alice/publicA bob/
cp bob/publicB alice/
echo

# create a message from Alice
msg="Hello Bob"
echo "Alice created a message $msg"
echo $msg > alice/msg.txt
echo

# Alice encodes the message
echo "Alice encoding message..."
echo

echo "Firstly, she creates the keysim."
openssl rand -out alice/keysim 16
echo "keysim generated is:"
cat alice/keysim
echo

echo "Then, she encodes the message into c1.txt"
openssl enc -e -in alice/msg.txt -out alice/c1.txt -kfile alice/keysim -aes-128-cbc -p
echo "The encoded message is:"
cat alice/c1.txt
echo

echo "Then, she encodes the keysim with bob's public key into c2.txt"
openssl rsautl -encrypt -in alice/keysim -out alice/c2.txt -pubin -inkey alice/publicB
echo "The encoded keysim is:"
cat alice/c2.txt
echo

echo "Then, she signs on the hashed keysim with her own private key into c3.txt"
openssl md5 alice/keysim > alice/hkeysim
openssl rsautl -sign -in alice/hkeysim -out alice/c3.txt -inkey alice/privateA
echo "The signed keysim is:"
cat alice/c3.txt
echo

echo "Then, she sends c1.txt, c2.txt and c3.txt to Bob"
cp alice/*.txt bob/
echo "Bob receives files as follows:"
ls bob | grep ".txt"
echo

# Bob decodes the message and verifies
echo "Bob decoding message..."
echo

echo "Bob decodes c2.txt with his private key for the keysim"
openssl rsautl -decrypt -in bob/c2.txt -out bob/keysim -inkey bob/privateB
echo "He finds the keysim is:"
cat bob/keysim
echo

echo "Then, he decodes c1.txt with the keysim for the message"
openssl enc -d -in bob/c1.txt -out bob/msg.txt -kfile bob/keysim -aes-128-cbc -p
echo "He finds the message be:"
cat bob/msg.txt
echo

echo "For verification, he then hashes the keysim he obtained into hkeysim"
openssl md5 bob/keysim | cut -f 2 -d= > bob/hkeysim
echo "The hashed keysim is:"
cat bob/hkeysim
echo

echo "He unsigns the c3.txt using the public key of Alice into vhkeysim"
openssl rsautl -verify -in bob/c3.txt -pubin -inkey bob/publicA | cut -f 2 -d= > bob/vhkeysim
echo "The verification keysim hash code is:"
cat bob/vhkeysim
echo

echo "He then compares hkeysim and vhkeysim"
DIFF=`diff bob/hkeysim bob/vhkeysim | wc -l`
diff bob/hkeysim bob/vhkeysim
echo "He finds $DIFF place(s) different."
echo