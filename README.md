# Opsins

This repository holds the gene-specific data and configuration for running
[PhylogenyPipeline](https://github.com/MartinGuehmann/PhylogenyPipeline) on
opsin genes. It is not runnable on its own; it supplies the bait sequences,
clade definitions, and the scripts that orchestrate the pipeline for this
particular gene family. See
[GeneFamilyTemplate](https://github.com/MartinGuehmann/GeneFamilyTemplate)
for a template to set up a repository like this one for a different gene
family.

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
	  Kick off gene-hit extraction (step 0; calls
	  Scheduler-00-ExtractSequences.sh). The "-NoContinue" variant stops
	  after step 0 instead of automatically continuing into sequence
	  processing (step 1). This break is deliberate too: step 0's
	  per-database searches (especially the remote NCBI ones — nr,
	  refseq_protein, swissprot, tsa_nr) can fail partway through from
	  network or NCBI-side issues, so it's worth checking `Hits/` (file
	  counts, no unexpectedly empty files) before trusting the extraction
	  and moving on.
	- 01_StartOpsinProcessing.sh / 01_StartOpsinProcessing-NoContinue.sh
	  Once step 0's output has been checked, this resumes the pipeline
	  from step 1 without repeating step 0. Kick off sequence processing
	  (steps 1 to 4; Scheduler-01-PrepareSequences.sh). The "-NoContinue"
	  variant stops
	  after step 4 instead of automatically continuing into
	  sequence-of-interest preparation (step 13). This break is
	  deliberate: continuing straight on risks handing the aligner and
	  tree builder in the final tree-building step a sequence set too
	  large to fit in memory. Before continuing, inspect the resulting
	  non-redundant sequence count, e.g.
	  `seqkit stats Sequences/NonRedundantSequences90.fasta`, then decide
	  whether to set `useFullDataset` (skips the pruning-guide-tree step
	  and hands the aligner the whole set — fine if it's small enough)
	  or leave it unset (prunes the set down with a guide tree first,
	  for a set too large to align and build a tree from directly).
	- 04_RestartOpsinProcessing.sh
	  Restart building the big combined sequence file (step 4;
	  Scheduler-04-ContinueMakeBigSequenceFile.sh), then automatically
	  continues into sequence-of-interest preparation (step 13;
	  13_RestartOpsinProcessing.sh's
	  Scheduler-13-ExtractSequencePreparation.sh) — there is no
	  "-NoContinue" variant of this script to stop that.
	- 13_RestartOpsinProcessing.sh
	  Restart preparing sequences of interest for extraction (step 13;
	  Scheduler-13-ExtractSequencePreparation.sh), then automatically
	  continues into extracting sequences of interest with PASTA
	  (Scheduler-14-ExtractSequencesOfInterestWithPASTA.sh) regardless of
	  any "continue" setting — again with no "-NoContinue" variant.
	- 15_RestartOpsinProcessing.sh
	  Restart tree building for sequence-of-interest extraction (step
	  15; Scheduler-15-ExtractSequencesOfInterestWithIQ-Tree.sh), then
	  automatically continues into tree building
	  (16_TreeBuildOpsinScheduler.sh's Scheduler-16-TreeBuildScheduler.sh)
	  — again with no "-NoContinue" variant.
	- 16_TreeBuildOpsinScheduler.sh
	  Restart tree building (Scheduler-16-TreeBuildScheduler.sh):
	  repeatedly runs the alignment/rogue-removal step (step 9) across
	  aligners to build the final trees. The final step; nothing to
	  continue into.

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

## Subdirectories

These follow PhylogenyPipeline's `$DIR/$gene/...` convention for per-gene
data (see its README). Some are inputs you curate by hand, the rest are
generated by a pipeline run.

Inputs:

	- BaitSequences/
	  Bait/seed sequences (fasta) used to search the protein databases
	  for hits.
	- AdditionalBaitSequences/
	  Extra bait sequences included alongside BaitSequences/.
	- MustKeepSequences/
	  Reference sequences that must survive non-redundancy filtering
	  regardless of similarity to other sequences, e.g. the bovine
	  rhodopsin sequence SpecialAminoAcid.sh uses to number Lys296.
	- OutgroupSequences/
	  Outgroup sequences added to the pruning-guide tree and used for
	  rooting.
	- RerootSequences/
	  Sequences used to reroot trees.

Generated by a pipeline run:

	- Hits/
	  Raw per-database BLAST hit tables from the initial gene search.
	- Sequences/
	  Collected candidate sequences and the non-redundant sequence sets
	  derived from them.
	- SeqenceChunksForPruning/
	  Sequence chunks split off for building the pruning-guide tree.
	- TreesForPruningFromPASTA/
	  PASTA trees built over those chunks, used to decide which
	  sequences to prune before the final alignment.
	- SequencesOfInterest/
	  The sequences selected for the final alignment and tree building.
	- Alignments/
	  The final multiple sequence alignments and resulting trees.

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
