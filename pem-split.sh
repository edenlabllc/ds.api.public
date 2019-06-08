#!/bin/bash
CERT_NAME=cert_
META=.meta
pemfile=chain.pem

openssl pkcs7 -in $p7bfile -inform DER -print_certs -out pemfile

if [ $1 ]
then
	if [ -f $1 ]
	then
		p7bfile=$1
	fi
else
	echo "Usage: split-pem.sh COMBINED-PEMFILE"
	exit 1
fi

#clear meta
echo '' > $META

pemformatparts=`grep -E "BEGIN.*PRIVATE KEY|BEGIN CERT" ${pemfile} 2> /dev/null | wc -l`
if [ ${pemformatparts} -lt 2 ]
then
	echo "ERROR: ${pemfile} is not combined PEM format"
	exit 1
fi

#split files
cnt=$(( $pemformatparts - 2 ))
csplit -k -f $CERT_NAME ${pemfile} '/END CERTIFICATE/+1' "{$cnt}"

for cert in $CERT_NAME*; do
 hexname=$(openssl x509 -noout -subject -in $cert | sed -n 's/^.*CN=\(.*\)$/\1/; s/[ ,.*]/_/g; s/__/_/g; s/^_//g;p' || true) ;
 subj=`echo -e $hexname | sed -e 's/[^A-Za-zА-я0-9._-]//g'`;
 echo "$cert	$subj" >> $META
 echo $subj
done
echo "META $pemfile updated"
exit 0
