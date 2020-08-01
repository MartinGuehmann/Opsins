#!/bin/bash

cat DAniello2015_Map.csv | while read line; do
	oldw="${line##* }";
	neww="${line%% *}";
#	echo $line;
#	echo $neww;
#	echo $oldw;
	sed -i "s/$oldw/$neww/g" "${1}"
done
