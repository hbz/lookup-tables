#!/bin/bash
FNAME_OUTPUT="isil2wikidata.csv"

curl -H "Accept: text/tab-separated-values" "https://query.wikidata.org/sparql?query=SELECT%20%3Fisil%20%3Fitem%0AWHERE%0A%7B%0A%20%20%3Fitem%20wdt%3AP791%20%3Fisil%20%20.%0A%20%20FILTER%20%28regex%28%3Fisil%2C%20%22%28AT%7CCH%7CDE%29-.%2a%22%29%29.%0A%7D" | grep wiki | tr -d '\015<>' | sort > $FNAME_OUTPUT 

lines=$(wc -l $FNAME_OUTPUT | cut -d ' ' -f1) 

if [ $lines -gt 5000 ]
then
	echo "Seems fine. Copying ..."
	mv $FNAME_OUTPUT ../data/
else
	echo "noop"
fi
