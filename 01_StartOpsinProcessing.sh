#!/bin/bash

# Get the directory where this script is
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
thisScript="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

gene=$(basename "$DIR")
bigTreeIteration="10"       # Actually this is default
aligner="PASTA"             # Is default
continue=""                 # Not default
numRoundsLeft="20"          # Is default
shuffleSeqs="--shuffleSeqs" # Shuffle the sequences between iterations of Rogue removal, this should be done
extension="-e contree"      # Extension of tree files to extract the sequences of interests from
trimAl="-t Default"         # Value for trimAl use Default value, values are between 0.0 and 1.0, default is 0.1.

qsub -v "DIR=$DIR, gene=$gene, bigTreeIteration=$bigTreeIteration, aligner=$aligner, continue=$continue, numRoundsLeft=$numRoundsLeft, shuffleSeqs=$shuffleSeqs, extension=$extension, trimAl=$trimAl" \
"$DIR/../PBS-Pro/PBS-Pro-01-PrepareSequences.sh"
