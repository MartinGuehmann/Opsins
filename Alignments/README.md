# Alignments/

Per-aligner subdirectories (`MAGUS/`, `MAFFT/`, `PASTA/`, etc.) hold each
round's alignment output, one `RogueIter_N/` subdirectory per rogue-removal
round.

## What `.gitignore` excludes here, and why

These file types from steps 9 (alignment), 10 (IQ-Tree tree building) and
12 (figures) are excluded because they're large, regenerable by rerunning
the relevant step on the same input, and not read by anything downstream:

- `*.mldist` - IQ-Tree's pairwise ML-distance matrix. Nothing reads it back.
- `*.ufboot` - IQ-Tree's ultrafast bootstrap trees. *Is* read downstream
  (`11_RemoveRogues.sh`), so it must exist on disk before step 11 runs -
  just not committed to git. Rerun step 10 to regenerate it.
- `*.png` - tree figures from step 12. Rerun step 12 from the tree files
  to get them back.
- `*.alignment.*.fasta` - the raw per-aligner alignment from step 9,
  excluded except for the `*treeSorted.fasta` variant, which is the
  versioned "final" alignment.
- `*.alignment.MAGUS/` - MAGUS's own scratch working directory
  (decomposition graph, subalignments, debug logs), passed to `magus -d`
  as pure workspace - nothing outside MAGUS ever reads it back. By far
  the biggest single contributor to repo size when tracked.

## Why this exists

Confirmed 2026-07-28 on `Mas1`: committing one MAGUS rogue-removal
round's full step 9/10 output produced a ~935 MB push that GitHub's SSH
transport repeatedly dropped mid-transfer, and required a history rewrite
+ force-push to fix once these patterns were identified. Added here
pre-emptively so the same push never gets made in the first place.
