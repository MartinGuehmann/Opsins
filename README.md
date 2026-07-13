# Opsins

This repository holds the gene-specific data and configuration for running
[PhylogenyPipeline](https://github.com/MartinGuehmann/PhylogenyPipeline) on
opsin genes. It is not runnable on its own; it supplies the bait sequences,
clade definitions, and the scripts that orchestrate the pipeline for this
particular gene family.

## Layout

This repository must be cloned as a sibling of `PhylogenyPipeline`, i.e.
both checked out next to each other under the same parent directory:

	some-parent-directory/
		PhylogenyPipeline/
		Opsins/

The scripts here call `../PhylogenyPipeline/...` directly, and pass the
pipeline `-g "../Opsins"` so that the pipeline writes its per-gene output
(`Hits/`, `Alignments/`, `SequencesOfInterest/`, etc.) back into this
repository instead of into `PhylogenyPipeline`.

## Running

	- 00_StartOpsinExtraction.sh / 00_StartOpsinExtraction-NoContinue.sh
	  Kick off gene-hit extraction (calls Scheduler-00-ExtractSequences.sh).
	  The "-NoContinue" variant stops after extraction instead of
	  automatically continuing into sequence processing.
	- 01_StartOpsinProcessing.sh / 01_StartOpsinProcessing-NoContinue.sh
	  Kick off sequence processing (Scheduler-01-PrepareSequences.sh).
	- 04_RestartOpsinProcessing.sh
	  Restart building the big combined sequence file
	  (Scheduler-04-ContinueMakeBigSequenceFile.sh).
	- 13_RestartOpsinProcessing.sh
	  Restart preparing sequences of interest for extraction
	  (Scheduler-13-ExtractSequencePreparation.sh).
	- 15_RestartOpsinProcessing.sh
	  Restart tree building for sequence-of-interest extraction
	  (Scheduler-15-ExtractSequencesOfInterestWithIQ-Tree.sh).
	- 16_TreeBuildOpsinScheduler.sh
	  Restart tree building (Scheduler-16-TreeBuildScheduler.sh).

Each of these picks the gene name up from its own directory name, so they
only work correctly when run from within this checkout.

## Standalone checks

	- CheckPlacopsins.sh compares the number of sequences above a support
	  threshold with and without an extra Placopsin bait sequence.
	- CheckForLysine.sh checks an alignment for a lysine (K) at the
	  position homologous to Lys296 of bovine rhodopsin, the retinal
	  Schiff-base attachment site.

## Configuration files

	- Clades.csv, Main_Clades.csv, Chromopsin_Clades.csv,
	  Placopsin_Clades.csv, Tetraopsins_Clades.csv, Outgroup_Clades.csv,
	  Xen-Main_Clades.csv
	  Reference sequence, clade label, and two colors per line, used to
	  color and label clades in the output tree figures. Each file
	  corresponds to a different clade-focused rerun of the pipeline for
	  this gene family. The last entry in each is used as the outgroup
	  for rooting the tree.
	- AdditionalTaxonIdentifiers.csv
	  Lookup table mapping misspelled or non-standard higher-taxon names
	  to their correct name in the NCBI taxon database.
	- InterestingTaxa.csv
	  Taxa to highlight with specific colors in the output trees.
	- NamesOfInterests.txt
	  Substrings (species/genus names) used to flag sequences of
	  interest.
	- AminoAcidColorMap.csv
	  Amino-acid-to-color mapping used in the visualized pie charts.
	- SpecialAminoAcids.txt / SpecialAminoAcid.sh
	  Config for 12_ConvertTreesToFigures.py: which amino acid position
	  (Lys296) to annotate in trees and sequence logos, and the reference
	  sequence it is numbered against.
	- MemArgForClans.txt
	  Java heap size argument passed to CLANS.

## Data

`Hits/`, `Alignments/`, `Sequences/`, `SequencesOfInterest/`,
`TreesForPruningFromPASTA/`, and the other generated directories are the
pipeline's output for this gene family and are tracked in git rather than
gitignored, so a full clone of this repository is large. To get just the
scripts and configuration above without the generated data, use a partial,
sparse clone:

	git clone --filter=blob:none --no-checkout git@github.com:MartinGuehmann/Opsins.git
	cd Opsins
	git sparse-checkout init --cone
	git sparse-checkout set
	git checkout master
