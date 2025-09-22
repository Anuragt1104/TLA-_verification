# Alpenglow Theorem Mapping

| Whitepaper Claim | TLA+ Artifact | Config / Notes |
| ---------------- | ------------- | --------------- |
| Fast-path finalization in one round with ≥80% responsive stake | `EventualFastFinalization`, `FastPathUnique`, `RegisterFastFinalAction` fairness (in `LiveSpec`) | `cfg/fast_path.cfg` (all validators honest, `SPECIFICATION LiveSpec`)
| Conservative finalization with ≥60% responsive stake | `EventualSlowFinalization`, `FinalizationImpliesNotar` | `cfg/slow_path.cfg`
| No two conflicting blocks finalize in the same slot | `NoDoubleFinalize`, `ChainConsistency` | `Alpenglow.cfg`, `cfg/resilience.cfg`
| Certificate uniqueness and notar/final soundness | `FastPathUnique`, `FinalizationImpliesNotar`, `SkipExcludesFinal` | Safety across all configs
| “20+20” resilience (≤20% Byzantine + ≤20% offline) | `EventualCoverage`, `EventualSlowFinalization` under `LiveSpec` fairness | `cfg/resilience.cfg` (Byzantine leader + offline stakeholder)
| Rotor non-equivocation / delivery fairness | `RotorAction` weak fairness in `LiveSpec`; `StakeSum` guard in `RotorDissemination` | All configs using `LiveSpec`
| Timeout-driven skip/fallback guarantees | `SkipActive`, `SkipExcludesFinal`, `HonestCanFallbackSkip` transitions | `cfg/slow_path.cfg`, `cfg/resilience.cfg`
| Finality chain consistency | `ChainConsistency`, ancestor closure in `RegisterFinalCertificate` | Safety across all configs

The safety invariants are exercised with `SPECIFICATION Spec`, while liveness claims require `SPECIFICATION LiveSpec` so that weak fairness on Rotor and honest voting actions models the paper’s partial synchrony assumption (`Δblock`, `Δtimeout`).
