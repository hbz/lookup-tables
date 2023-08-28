#!/bin/bash
# author: dr0i + TobiasNx
# date: 2023-03-06
# description:
# Build the table "generatedAlmaSuppressedLocations.tsv" with two columns
# "MainLibraryCode+SublibraryCode ISIL" from files residing in data/almaSuppressedLocations/
# directory which have two columns "almaSuppressedLocations status". Structure like this:
# "49HBZ_" + $filenameExludingSuffix + "+" +  $currentLocation" $separator $status
#
# see https://github.com/hbz/lobid-resources/issues/1639.
#
# invoke: $ bash almaSublibraryCode2Isil.sh
# result will be in ../data/almaSublibraryCode2Isil/generated/generatedAlmaSuppressedLocations.tsv

MAIN_LIBRARY_CODE="49HBZ_"
GENERATED_FILE="generated/generatedAlmaSuppressedLocations.tsv"
cd ../data/almaSuppressedLocations
rm $GENERATED_FILE.tmp

for fn in $(ls); do
	echo $fn
	IFS=$'\n' # read whole lines
	for rows in $(cat $fn); do
			echo "zeile: $rows"
			libraryCode=$(echo $rows | cut -f1)
			isil=$(echo $rows | cut -f2)
			echo "${MAIN_LIBRARY_CODE}$(echo $fn|cut -d '.' -f1)+${libraryCode}	${isil}" >> $GENERATED_FILE.tmp
	done
done

echo "MainLibraryCode+AlmaSuppressedLocations	status" > $GENERATED_FILE
sort $GENERATED_FILE.tmp >> $GENERATED_FILE
rm $GENERATED_FILE.tmp
