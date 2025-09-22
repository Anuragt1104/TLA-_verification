# Alpenglow Verification Strategy

## 1. Protocol Understanding
- **Votor dual-path finalization**: Concurrent fast (≥80% stake) and conservative (≥60%) voting, sharing the same initial notarization round. Algorithm 1/2 specify event-driven voting, fallback triggers, and timeout-driven skip logic. Nodes maintain per-slot state (`Voted`, `VotedNotar`, `BlockNotarized`, `ItsOver`, `BadWindow`) and operate on `Pool` events.
- **Rotor dissemination**: Leaders erasure-code each slice, sample stake-weighted relays, and rely on relay rebroadcast in descending stake order. Assumptions ensure non-equivocation within slices and probabilistic guarantees of delivery despite ≤20% Byzantine + ≤20% crash faults.
- **Certificates**: Notarization, notar-fallback, skip, skip-fallback, fast-finalization, and finalization certificates follow stake thresholds (Table 6). `SafeToNotar` and `SafeToSkip` events prevent conflicting fast finalization.
- **Leader windows**: Slots are grouped by a VRF-derived schedule; timeouts are staged per window using `Δblock` and `Δtimeout`. Skip logic covers leader failure, ensuring per-slot coverage by either notarized block or skip certificate.

## 2. Modeling Assumptions
- Finite node set `Nodes` with stake function `Stake` (`Σ Stake = 1`). Model small networks (4–10 nodes) for exhaustive checks.
- Discrete slots `Slots = 0..SlotCount-1` with leader mapping `Leader(s)`. Window size `W` is small (e.g., 2–4) for TLC feasibility.
- Message transport is abstracted as reliable but asynchronous queues with optional adversarial delivery to capture Rotor variance. Rotor failures are modeled as non-delivery of some shreds up to probabilistic bounds; for TLC we use nondeterministic loss bounded by adversary power.
- Timers expressed as logical events (`Timeout(slot)`) issued when scheduled and not yet fired.
- Byzantine behaviors limited to equivocation in block production and vote casting, constrained by stake budgets per requirement (≤20% for safety, extra ≤20% offline for liveness experiments).

## 3. Specification Decomposition
1. **Node State Machine**: Encodes Algorithm 1 event loop and Algorithm 2 helpers, including notarization, skip, fallback, and finalization transitions with explicit state predicates (`HonestCanNotar`, `HonestCanFallbackSkip`, etc.).
2. **Rotor Abstraction**: Models stake-weighted dissemination (`RotorAction`) and enforces that a node only reconstructs a block once enough prior stake has already received it.
3. **Certificates & Pool**: Aggregates votes and certificates via derived sets (`HasNotarCert`, `HasSkipCert`, `SlotFinalizedBlocks`) and ensures ancestors finalize atomically when certificates arrive.
4. **Leader / Window Logic**: Maintains `WindowRoot`, parent readiness, and staged timeouts with fairness assumptions over the enabling actions (`MarkParentReadyAction`, `ScheduleTimeoutAction`).
5. **Adversary Module**: Permits equivocation, vote-doubling, and selective finalization attempts bounded by the configured `Byzantine` stake; offline stake is modeled as nodes outside `Honest ∪ Byzantine`.

## 4. Properties for Verification
- **Safety**:
  - `NoDoubleFinalize`, `ChainConsistency`, `FastPathUnique`, `FinalizationImpliesNotar`, and `SkipExcludesFinal` cover the paper’s theorems on certificate uniqueness, non-equivocation, and notar/final consistency.
  - `TypeOK`/`HonestVoteUniqueness` protect against malformed state encodings and multiple honest votes per slot.
- **Liveness**:
  - `EventualCoverage`, `EventualFastFinalization`, and `EventualSlowFinalization` capture the fast (≥80%) and conservative (≥60%) paths under the fairness-constrained `LiveSpec`.
  - Fairness clauses (`WF_vars` on Rotor/voting actions) encode the partial synchrony guarantees described for `Δblock` and `Δtimeout`.
- **Resilience**:
  - `cfg/resilience.cfg` instantiates the “20+20” scenario (≤20% Byzantine, ≤20% offline) to demonstrate continued coverage and slow-path finalization.
  - Byzantine command actions test equivocation, double-voting, and unauthorized finalization attempts.

Each property will be encoded either as state invariants (`INV`) or temporal formulas (`[]`/`<>`), with auxiliary lemmas to restrict state space (e.g., honest stake monotonicity).

## 5. Verification Workflow
- **Abstraction tuning**: The current model fuses Votor logic with stake-weighted Rotor delivery. Further refinements can tighten Rotor fairness (e.g., probabilistic sampling) without changing the existing interfaces.
- **Model checking**: Run TLC on the supplied configs (`make safety`, `make fast`, `make slow`, `make resilience`). Symmetry reduction remains optional for the small topologies.
- **Proof scripts**: TLAPS skeletons remain to be added; `THEOREM` clauses in `Alpenglow.tla` mark the obligations to discharge.
- **Testing guidance**: Each config exercises a distinct theorem bucket: safety baseline, fast path, slow path with partial synchrony, and “20+20” resilience. Extend with additional configs as new scenarios arise.

## 6. Next Steps
1. Add TLAPS proofs for the declared `THEOREM`s; stratify lemmas into a companion `AlpenglowLemmas.tla`.
2. Extend Rotor modeling with probabilistic relay choice (for statistical checking) or integrate with Apalache for Monte Carlo runs.
3. Add larger-node TLC scenarios with symmetry reduction to stress-test certificate uniqueness at scale.
4. Draft the technical report summarizing verification coverage and connect each paper theorem to the matching TLA+ property.
