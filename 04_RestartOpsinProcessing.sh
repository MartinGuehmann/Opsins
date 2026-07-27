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
gene="../$gene"
source "$DIR/Config.sh"

# Rebuilding NonRedundantSequences90.fasta/reshuffling SequencesOfInterest
# (steps 4/17 further down this chain) silently breaks anything already
# aligned/tree-built from the current files - confirmed 2026-07-26 when
# this script got run by mistake instead of 13_RestartProcessing.sh.
# Those steps now skip instead of clobbering unless told otherwise here.
overwrite=""
if [ "$1" == "--overwrite" ]
then
	overwrite="--overwrite"
fi

"$DIR/../PhylogenyPipeline/Scheduler/Scheduler-04-ContinueMakeBigSequenceFile.sh" -g $gene -b $bigTreeIteration -a $aligner $continue -n $numRoundsLeft -N $bigNumRoundsLeft $shuffleSeqs -e $extension -t $trimAl $overwrite
