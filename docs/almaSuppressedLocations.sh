#!/bin/bash
# author: dr0i + TobiasNx
# date: 2023-03-06
# description:
# Build the table "generatedAlmaSuppressedLocations.tsv" with two columns
# "MemberCode[+LibraryCode]+LocationCode	status" from files residing in data/almaSuppressedLocations/
# directory which have three columns "LibraryCode	LocationCode	status". Structure like this:
# - if LibraryCode exists:
# "49HBZ_" + $filenameExludingSuffix + "+" + $libraryCode + "+" + $locationCode $separator $status
# - otherwise:
# "49HBZ_" + $filenameExludingSuffix + "+" + $locationCode $separator $status
#
# see https://github.com/hbz/lobid-resources/issues/1639.
#
# invoke: $ bash almaSuppressedLocations.sh
# result will be in ../data/almaSuppressedLocations/generated/generatedAlmaSuppressedLocations.tsv

MAIN_LIBRARY_CODE="49HBZ_"
GENERATED_FILE="generated/generatedAlmaSuppressedLocations.tsv"
cd ../data/almaSuppressedLocations
rm $GENERATED_FILE.tmp

for fn in $(ls); do
	echo "$fn"
	IFS=$'\n' # read whole lines
	for rows in $(cat "$fn"); do
			echo zeile: "$rows"
			libraryCode=$(echo "$rows" | cut -f1)
			locationCode=$(echo "$rows" | cut -f2)
			status=$(echo "$rows" | cut -f3)
			echo "${MAIN_LIBRARY_CODE}$(echo "$fn"|cut -d '.' -f1)${libraryCode:++}${libraryCode}+${locationCode}	${status}" >> $GENERATED_FILE.tmp
	done
done

echo "MemberCode[+LibraryCode]+LocationCode	status" > $GENERATED_FILE
sort $GENERATED_FILE.tmp >> $GENERATED_FILE
rm $GENERATED_FILE.tmp
