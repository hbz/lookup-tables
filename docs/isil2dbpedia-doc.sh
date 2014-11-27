
#!/bin/bash
# 2014-11-27
# these scripts are old won't work now, e.g. we don't use a SPARQL db anymore.
# However, this script gives you the idea how the lookup-table was build.

# get the existing lookup-table from gbv:
wget 'http://ws.gbv.de/wpextract/dewiki-isil.beacon' -O dewiki-isil-gbv.beacon


# get all title strings and make a lookup with these in wikipedia and persist the pages in filesystem:
for i in $(grep foaf:name ../../lobid-organisations1.ttl | cut -d '"' -f2 | sed -e 's#\ #_#g' ); do  wget "https://de.wikipedia.org/wiki/$i"; done

# lookup the filenames in the SPARQL database for validation. Only
# if exactly one hit is in the result build the lookup-table with it.

rm zz_beacon.txt
function lookup() {
	WIKI_NAME=$1
	NAME=$(echo $1| sed -e 's#_# #g')
	QUERY_COUNT="
	prefix foaf: <http://xmlns.com/foaf/0.1/>
	prefix dct: <http://purl.org/dc/terms/>
	SELECT DISTINCT (COUNT( distinct ?id) AS ?count) WHERE {
	?s foaf:name\"$NAME\" ;
	 dct:identifier ?id .
	}"

	count=$(curl -H "Accept: text/plain"  --data-urlencode "query=$QUERY_COUNT
	" http://test.lobid.org/sparql/)
	count=$(echo "$count" | sed -e 's#\?count##g;s#"\(.*\)".*#\1#g') 
	
	if [ $count -eq 1 ]; then 
		QUERY="
		prefix foaf: <http://xmlns.com/foaf/0.1/>
		prefix dct: <http://purl.org/dc/terms/>
		SELECT ?id WHERE {
		?s foaf:name\"$NAME\" ;
		 dct:identifier ?id .
		}"

		id=$(curl -H "Accept: text/plain"  --data-urlencode "query=$QUERY
		" http://test.lobid.org/sparql/)
		id=$(echo "$id" | sed -e "s#\?id##g")
		if [ $(expr length "$id") -gt 3 ]; then 
			id=$(echo "$id" | sed -e 's#"##g')"|"
			printf "$id$WIKI_NAME" >> zz_beacon.txt
		fi
	fi
}

for i in $(ls); do lookup $i  ; done
echo "Wenn alles ok, dann:$ mv zz_beacon.txt /files/open_data/open/DE-605/enrich/isil-dewiki.beacon"

