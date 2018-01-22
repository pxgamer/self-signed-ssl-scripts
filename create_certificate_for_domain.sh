if [ -z "$1" ]
then
  echo "Please supply a subdomain to create a certificate for...";
  echo "e.g. dev.local"
  exit;
fi

# Create a new private key if one doesnt exist, or use the xeisting one if it does
if [ -f device.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

DOMAIN=$1
mkdir $DOMAIN
SUBJECT="//C=CA/ST=None/L=NB/O=None/CN="$DOMAIN
NUM_OF_DAYS=999
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT device.key -subj "$SUBJECT" -out device.csr
cat v3.ext | sed s/%%DOMAIN%%/$DOMAIN/g > /tmp/__v3.ext
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days $NUM_OF_DAYS -sha256 -extfile /tmp/__v3.ext 

# move output files to final filenames
mv device.csr $DOMAIN/$DOMAIN.csr
cp device.crt $DOMAIN/$DOMAIN.crt
cp device.key $DOMAIN/device.key

# remove temp file
rm -f device.crt;

echo 
echo "###########################################################################"
echo Done! 
echo "###########################################################################"
echo "To use these files on your server, simply copy both $DOMAIN.csr and"
echo "device.key to your webserver, and use like so (if Apache, for example)."
echo "For IIS, run the 'create_pfx_for_iis.sh' to generate your PFX file."
echo 
