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

extension="treefile"
TreesForPruningFromPASTADir="$DIR/TreesForPruningFromPASTA"
SequenceChunksForPruningDir="$DIR/SeqenceChunksForPruning"
extraSeqFile="$DIR/AdditionalBaitSequences/B3RY65_Trichoplax_adhaerens_GPCR.fasta"
threshold="200"

numPlacopsin=$("$DIR/../16_ExtractSequencesOfInterest.sh" -j -g $gene -d $TreesForPruningFromPASTADir -c $SequenceChunksForPruningDir -e $extension -t $threshold -f $extraSeqFile)
numWithout=$("$DIR/../16_ExtractSequencesOfInterest.sh" -j -g $gene -d $TreesForPruningFromPASTADir -c $SequenceChunksForPruningDir -e $extension -t $threshold)

echo "Num above threshold with Placopsins: $numPlacopsin"
echo "Num above threshold without Placopsins: $numWithout"
