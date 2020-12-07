#!/bin/bash

# Get the directory where this script is
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

alignmentFile=$1
numThreads=$(nproc)     # Get the number of the currently available processing units to this process, which maybe less than the number of online processors
theLysinePosition=296
bovineRhdopsinID="001014890"

bovineRhdopsin=$(seqkit grep -w 0 -r -p $bovineRhdopsinID -j $numThreads $alignmentFile)
bovineRhdopsin=${bovineRhdopsin#*$'\n'}

pos=0

for (( i=0; i<${#bovineRhdopsin}; i++ ))
do
	if [[ "${bovineRhdopsin:$i:1}" != "-" ]]
	then
		((pos++))
	fi

	if [[ $pos == $theLysinePosition ]]
	then
		break
	fi
done

echo $i
echo "${bovineRhdopsin:$i:1}"

numLysins=0
numGaps=0
numSequences=0

while read line
do
	if [[ "${line:0:1}" == ">" ]]
	then
		ID=$line
	else
		((numSequences++))
		if [[ "${line:$i:1}" == "K" || "${line:$i:1}" == "k" ]]
		then
			((numLysins++))
		fi
		
		if [[ "${line:$i:1}" == "-" ]]
		then
			((numGaps++))
		fi
	fi
done < $alignmentFile

echo $numSequences
echo $numLysins
echo $numGaps
