# Verification Properties and Test Plan

## Core Safety Invariants
- **TypeOK**: Maintains domain constraints for every variable. Guards TLC state space from ill-typed states.
- **HonestVoteUniqueness**: Ensures an honest validator emits at most one notarization vote per slot.
- **NoDoubleFinalize**: Prevents conflicting finalized blocks in the same slot.
- **ChainConsistency**: Finalized blocks lie on a single ancestor chain thanks to ancestor-closure of finalization.
- **FinalizationImpliesNotar**: Every finalized block retains a notarization certificate (covers Definition 14).
- **SkipExcludesFinal**: A skip certificate blocks any finalization for that slot.
- **FastPathUnique**: At most one block per slot can accumulate an 80% fast-finalization certificate.

## Liveness Objectives
- **EventualCoverage**: Under `LiveSpec` fairness, each slot eventually gains a notarization certificate or skip certificate (`PROPERTY EventualCoverage`).
- **EventualFastFinalization**: If ≥80% stake is honest, every slot fast-finalizes (`PROPERTY EventualFastFinalization`).
- **EventualSlowFinalization**: With ≥60% honest stake, slow-path finalization is guaranteed (`PROPERTY EventualSlowFinalization`).

## Resilience Scenarios
1. **Byzantine Leader**: `Alpenglow.cfg` includes a Byzantine validator capable of equivocation; safety invariants remain green.
2. **Fast Path**: `cfg/fast_path.cfg` enables full honesty to exhibit one-round finalization.
3. **Slow Path with Offline Stake**: `cfg/slow_path.cfg` leaves ≥20% stake offline while maintaining ≥60% honest participation.
4. **“20+20” Resilience**: `cfg/resilience.cfg` places 20% stake Byzantine and 20% offline, validating coverage and slow-path liveness.

## TLC Configurations
- `Alpenglow.cfg`: 4-node baseline (3 honest, 1 Byzantine) checking safety invariants.
- `cfg/fast_path.cfg`: All nodes honest (≥80% stake) to witness fast path liveness.
- `cfg/slow_path.cfg`: Honest stake ≥60% with a Byzantine validator, confirming slow-path progress.
- `cfg/resilience.cfg`: “20+20” mix with Byzantine leader and offline stake, stressing coverage under adversarial behavior.

## Tooling Workflow
1. Use the `Makefile` targets: `make safety`, `make fast`, `make slow`, `make resilience`. Each invokes TLC with the appropriate configuration.
2. Adjust `TLC`/`MODEL` via environment variables if tooling lives elsewhere (e.g., `TLC='java -jar tla2tools.jar'`).
3. Develop TLAPS proofs in a companion module—the current `THEOREM` clauses flag pending obligations.
4. For statistical exploration, extend the model with randomized Rotor sampling or integrate Apalache once required.

## Next Implementation Tasks
1. Encode `ChainConsistency` and `CertificateSoundness` as invariants once auxiliary functions are finalized.
2. Add fairness (`WF_vars`) assumptions for key actions (Rotor delivery, timer firing) to enable liveness properties.
3. Build additional TLC configs covering resilience scenarios.
4. Document modeling abstractions and map each paper theorem to its TLA+ representation in the upcoming technical report.
