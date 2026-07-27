# SequencesOfInterest/

This is where the rogue-removal loop (step 11, `RunAll.sh`) keeps each
round's working sequence set, one `RogueIter_N/` subdirectory per round
(`RogueIter_0` is the starting set, before any rogue removal has run).

## Files inside a `RogueIter_N/` directory

- `SequencesOfInterest.fasta` - the full, unsplit set of sequences for
  this round.
- `SequencesOfInterestShuffled.fasta` - the same set, randomly shuffled,
  before being split into chunks.
- `SequencesOfInterestShuffled.part_NNN.fasta` - the actual chunks
  (~900 sequences each by default) that get aligned/tree-built
  individually.

## Where `.dropped.fasta`/`.old.fasta` come from

Right after a round of rogue removal finishes, `RogueIter_(N+1)/` has
three files per part - a plain `part_NNN.fasta` alongside
`part_NNN.dropped.fasta` and `part_NNN.old.fasta`. That's two scripts
running one after another, not one script writing three related files:

1. `11_RemoveRogues.sh` runs once per alignment part of the *previous*
   round (`RogueIter_N`) and writes, into `RogueIter_(N+1)`:
   - `part_NNN.dropped.fasta` - the sequences RogueNaRok/TreeShrink
     flagged as rogues *from that specific old part*.
   - `part_NNN.fasta` - the survivors *from that specific old part*,
     still organized by the old per-part boundaries.

2. `11b_ExtractNonRogues.sh` then runs once, across all parts together:
   it pools every part's survivors into one whole-gene
   `SequencesOfInterest.fasta`, and - if `shuffleSeqs`/`-l` is on
   (`Config.sh`'s `shuffleSeqs="--shuffleSeqs"`) - renames the per-part
   survivor files written in step 1 to `part_NNN.old.fasta` (so they're
   out of the way), then reshuffles and re-splits the *entire pooled
   set* from scratch into fresh `part_NNN.fasta` files.

The result: `.dropped.fasta` is genuinely tied to old part NNN.
`.old.fasta` is also tied to old part NNN (its survivors, now
superseded). But the plain `part_NNN.fasta` sitting next to them is a
brand-new file with no continuity to either - it's an arbitrary slice
of the reshuffled whole-gene survivor pool, drawn from across all
parts, not just old part NNN. Part numbering does not carry meaning
across rounds when shuffling is on.
