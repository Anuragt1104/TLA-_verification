---- MODULE Alpenglow ----
EXTENDS Naturals, FiniteSets, Sequences, TLC

(*******************************************************************)
(*                       Constants                                 *)
(*******************************************************************)
CONSTANTS 
    Nodes,          \* All validators participating in the protocol
    Honest,         \* Subset of Nodes behaving according to Votor
    Byzantine,      \* Complement of Honest (assumed to satisfy Honest ∪ Byzantine = Nodes)
    Slots,          \* Finite set of slot identifiers, totally ordered
    WindowSize,     \* Size of the leader window in slots
    ThresholdFast,  \* Fast finalization threshold (e.g. 80)
    ThresholdSlow,  \* Slow finalization threshold (e.g. 60)
    ThresholdFallback, \* Minimum notar stake for SafeToNotar (e.g. 20)
    DeltaFast,      \* Abstract latency bound for fast path
    DeltaSlow       \* Abstract latency bound for slow path (2 * Delta60 in paper)

None == [slot |-> 0 - 2, tag |-> "NONE"]

(*******************************************************************)
(*                       Derived domains & Helper functions         *)
(*******************************************************************)
RECURSIVE MinVal(_)
MinVal(S) == IF S = {} THEN 0 ELSE LET x == CHOOSE e \in S : TRUE IN
    IF S = {x} THEN x ELSE LET m == MinVal(S \ {x}) IN IF x < m THEN x ELSE m

FirstSlot == MinVal(Slots)

\* Default model values for complex constants
GenesisBlock == [slot |-> 0 - 1, tag |-> "G"]
Leader == [s \in Slots |-> CHOOSE n \in Nodes : TRUE]
Stake == [n \in Nodes |-> 25]
BlockOptions == [s \in Slots |-> {[slot |-> s, tag |-> "A"]}]

BlockIds == UNION { BlockOptions[s] : s \in Slots }

ParentOf == [b \in BlockIds \cup {GenesisBlock} |->
    IF b = GenesisBlock THEN GenesisBlock
    ELSE IF b.slot \in Slots /\ b.slot > FirstSlot
         THEN LET prevSlot == b.slot - 1
              IN CHOOSE pb \in BlockOptions[prevSlot] : TRUE
         ELSE GenesisBlock]

ASSUME Honest \subseteq Nodes /\ Byzantine \subseteq Nodes
ASSUME Honest \cap Byzantine = {} /\ Honest \cup Byzantine = Nodes
ASSUME \A s \in Slots : \A b \in BlockOptions[s] : b.slot = s
ASSUME ParentOf[GenesisBlock] = GenesisBlock
ASSUME \A s \in Slots : \A b \in BlockOptions[s] : ParentOf[b] \in (BlockIds \cup {GenesisBlock})
ASSUME \A s \in Slots : \A b \in BlockOptions[s] : ParentOf[b] # b
ASSUME \A s \in Slots : \A b \in BlockOptions[s] :
    (ParentOf[b] = GenesisBlock) \/ (ParentOf[b].slot < s)

SlotOf(b) == IF b = GenesisBlock THEN FirstSlot ELSE b.slot

\* Default fallback for ParentOf on genesis
Parent(b) == IF b = GenesisBlock THEN GenesisBlock ELSE ParentOf[b]

RECURSIVE StakeSum(_)
StakeSum(S) == IF S = {} THEN 0 ELSE LET n == CHOOSE v \in S : TRUE IN Stake[n] + StakeSum(S \ {n})

RECURSIVE MaxVal(_)
MaxVal(S) == IF S = {} THEN 0 ELSE LET x == CHOOSE e \in S : TRUE IN
    IF S = {x} THEN x ELSE LET m == MaxVal(S \ {x}) IN IF x > m THEN x ELSE m

WindowStart(s) == s - ((s - FirstSlot) % WindowSize)

WindowSlots(s) == { WindowStart(s) + i : i \in 0..(WindowSize - 1) } \cap Slots

IsFirstInWindow(s) == s = WindowStart(s)

WindowRoot(s) == WindowStart(s)

\* Helper for collecting candidate blocks per slot within the domain.
SlotBlocks(s) == BlockOptions[s]

(*******************************************************************)
(*                       State variables                           *)
(*******************************************************************)
VARIABLES 
    produced,           \* Subset of BlockIds that have been produced by leaders
    delivered,          \* [Nodes -> SUBSET BlockIds] blocks each node has reconstructed
    notarVotes,         \* [Slots -> [BlockIds -> SUBSET Nodes]] notar votes per slot & block
    notarFallbackVotes, \* [Slots -> [BlockIds -> SUBSET Nodes]] notar-fallback votes
    skipVotes,          \* [Slots -> SUBSET Nodes] skip votes (initial)
    skipFallbackVotes,  \* [Slots -> SUBSET Nodes] skip fallback votes
    finalVotes,         \* [Slots -> [Nodes -> BlockIds \cup {GenesisBlock, None}]]
    parentReady,        \* [Slots -> BOOLEAN] indicates ParentReady observable globally
    timeoutsArmed,      \* [Slots -> BOOLEAN] slot timeouts scheduled for the window
    timeoutsFired,      \* [Slots -> BOOLEAN] slot timeouts fired
    finalized,          \* SUBSET BlockIds finalized (slow or fast)
    fastFinalized,      \* SUBSET BlockIds fast-finalized
    notarizedBlocks     \* SUBSET BlockIds with slow notar certificate

vars == << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
            skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
            timeoutsFired, finalized, fastFinalized, notarizedBlocks >>

(*******************************************************************)
(*                       Initialisation                            *)
(*******************************************************************)
Init == 
    /\ produced = {GenesisBlock}
    /\ delivered = [n \in Nodes |-> {GenesisBlock}]
    /\ notarVotes = [s \in Slots |-> [b \in BlockIds |-> {}]]
    /\ notarFallbackVotes = [s \in Slots |-> [b \in BlockIds |-> {}]]
    /\ skipVotes = [s \in Slots |-> {}]
    /\ skipFallbackVotes = [s \in Slots |-> {}]
    /\ finalVotes = [s \in Slots |-> [n \in Nodes |-> None]]
    /\ parentReady = [s \in Slots |-> FALSE]
    /\ timeoutsArmed = [s \in Slots |-> FALSE]
    /\ timeoutsFired = [s \in Slots |-> FALSE]
    /\ finalized = {GenesisBlock}
    /\ fastFinalized = {}
    /\ notarizedBlocks = {GenesisBlock}

(*******************************************************************)
(*                   Helper predicates & derived sets              *)
(*******************************************************************)
DomainBlocks(s) == SlotBlocks(s)

BlockStake(s, b) == StakeSum(notarVotes[s][b])

FallbackStake(s, b) == StakeSum(notarVotes[s][b] \cup notarFallbackVotes[s][b])

SkipStake(s) == StakeSum(skipVotes[s])

SkipFallbackStake(s) == StakeSum(skipVotes[s] \cup skipFallbackVotes[s])

FinalStake(s, b) == StakeSum({ n \in Nodes : finalVotes[s][n] = b })

TotalNotarStake(s) == StakeSum(UNION { notarVotes[s][b] : b \in DomainBlocks(s) })

MaxNotarStake(s) == MaxVal({ BlockStake(s, b) : b \in DomainBlocks(s) })

SafeToNotar(s, b) == 
    /\ parentReady[WindowRoot(s)]
    /\ StakeSum(notarVotes[s][b]) >= ThresholdFallback
    /\ SkipStake(s) + StakeSum(notarVotes[s][b]) >= ThresholdSlow

SafeToSkip(s) == SkipStake(s) + TotalNotarStake(s) - MaxNotarStake(s) >= ThresholdSlow - ThresholdFallback

HasNotarCert(s, b) == BlockStake(s, b) >= ThresholdSlow

HasFastFinalCert(s, b) == BlockStake(s, b) >= ThresholdFast

HasNotarFallbackCert(s, b) == FallbackStake(s, b) >= ThresholdSlow

HasSkipCert(s) == SkipFallbackStake(s) >= ThresholdSlow

HasFinalCert(s, b) == FinalStake(s, b) >= ThresholdSlow

Finalizable(s, b) == HasNotarCert(s, b) /\ ~HasSkipCert(s)

\* A block is admissible if its parent chain already finalized or notarized
BlockAdmissible(b) == 
    IF b = GenesisBlock THEN TRUE
    ELSE Parent(b) \in notarizedBlocks \cup finalized

RECURSIVE Ancestors(_)
Ancestors(b) == IF b = GenesisBlock THEN {GenesisBlock}
    ELSE {b} \cup Ancestors(Parent(b))

SlotFinalizedBlocks(s) == { b \in BlockIds : SlotOf(b) = s /\ b \in finalized }

SkipActive(s) == HasSkipCert(s)

NotarizedBlocks(s) == { b \in BlockIds : SlotOf(b) = s /\ HasNotarCert(s, b) }

SlotCovered(s) == (\E b \in DomainBlocks(s) : HasNotarCert(s, b)) \/ SkipActive(s)

SlotFinalized(s) == SlotFinalizedBlocks(s) # {}

SlotFastFinalized(s) == \E b \in DomainBlocks(s) : b \in fastFinalized

FastPathReady == StakeSum(Honest) >= ThresholdFast

SlowPathReady == StakeSum(Honest) >= ThresholdSlow

EventualCoverage == \A s \in Slots : <>SlotCovered(s)

EventualSlowFinalization == \A s \in Slots : [] (SlowPathReady => <> SlotFinalized(s))

EventualFastFinalization == \A s \in Slots : [] (FastPathReady => <> SlotFastFinalized(s))

\* Honest nodes must avoid double voting while reacting to fallback triggers.
HonestReadyBase(n, s) ==
    /\ n \in Honest
    /\ parentReady[WindowRoot(s)]

HonestHasVoted(n, s) ==
    (n \in skipVotes[s]) \/ (\E b \in DomainBlocks(s) : n \in notarVotes[s][b])

HonestCanNotar(n, s, b) == 
    /\ HonestReadyBase(n, s)
    /\ ~HonestHasVoted(n, s)
    /\ b \in DomainBlocks(s)
    /\ {b, Parent(b)} \subseteq delivered[n]

HonestCanSkipTimeout(n, s) ==
    /\ HonestReadyBase(n, s)
    /\ ~HonestHasVoted(n, s)
    /\ timeoutsFired[WindowRoot(s)]
    /\ SlotFinalizedBlocks(s) = {}  \* Cannot skip if slot already finalized

HonestCanFallbackNotar(n, s, b) == HonestReadyBase(n, s) /\ HonestHasVoted(n, s) /\ SafeToNotar(s, b)

HonestCanFallbackSkip(n, s) == 
    /\ HonestReadyBase(n, s) 
    /\ HonestHasVoted(n, s) 
    /\ SafeToSkip(s)
    /\ SlotFinalizedBlocks(s) = {}  \* Cannot skip if slot already finalized

HonestCanFinalVote(n, s, b) ==
    /\ n \in Honest
    /\ finalVotes[s][n] = None
    /\ n \in notarVotes[s][b]
    /\ HasNotarCert(s, b)
    /\ ~HasSkipCert(s)

(*******************************************************************)
(*                       Actions                                   *)
(*******************************************************************)
ProduceBlock(s, b) ==
    /\ s \in Slots
    /\ b \in DomainBlocks(s)
    /\ b \notin produced
    /\ Leader[s] \in Nodes
    /\ BlockAdmissible(b)
    /\ produced' = produced \cup {b}
    /\ delivered' = [delivered EXCEPT ![Leader[s]] = delivered[Leader[s]] \cup {b}]
    /\ UNCHANGED << notarVotes, notarFallbackVotes, skipVotes, skipFallbackVotes,
                    finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

ScheduleTimeout(s) ==
    /\ IsFirstInWindow(s)
    /\ parentReady[s]
    /\ ~timeoutsArmed[s]
    /\ timeoutsArmed' = [timeoutsArmed EXCEPT ![s] = TRUE]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

FireTimeout(s) ==
    /\ IsFirstInWindow(s)
    /\ timeoutsArmed[s]
    /\ ~timeoutsFired[s]
    /\ timeoutsFired' = [timeoutsFired EXCEPT ![s] = TRUE]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    finalized, fastFinalized, notarizedBlocks >>

HonestNotarize(n, s, b) ==
    /\ HonestCanNotar(n, s, b)
    /\ b \in produced
    /\ notarVotes' = [notarVotes EXCEPT ![s][b] = notarVotes[s][b] \cup {n}]
    /\ delivered' = delivered
    /\ UNCHANGED << produced, notarFallbackVotes, skipVotes, skipFallbackVotes,
                    finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

HonestSkip(n, s) ==
    /\ HonestCanSkipTimeout(n, s)
    /\ skipVotes' = [skipVotes EXCEPT ![s] = skipVotes[s] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired, finalized, fastFinalized, notarizedBlocks >>

HonestFallbackNotar(n, s, b) ==
    /\ HonestCanFallbackNotar(n, s, b)
    /\ notarFallbackVotes' = [notarFallbackVotes EXCEPT ![s][b] = notarFallbackVotes[s][b] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, skipVotes, skipFallbackVotes,
                    finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

HonestFallbackSkip(n, s) ==
    /\ HonestCanFallbackSkip(n, s)
    /\ skipFallbackVotes' = [skipFallbackVotes EXCEPT ![s] = skipFallbackVotes[s] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes,
                    skipVotes, finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

HonestFinalVote(n, s, b) ==
    /\ HonestCanFinalVote(n, s, b)
    /\ finalVotes' = [finalVotes EXCEPT ![s][n] = b]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

RegisterNotarCertificate(s, b) ==
    /\ HasNotarCert(s, b)
    /\ b \notin notarizedBlocks
    /\ notarizedBlocks' = notarizedBlocks \cup {b}
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired, finalized, fastFinalized >>

RegisterFastFinalCertificate(s, b) ==
    /\ HasFastFinalCert(s, b)
    /\ b \notin fastFinalized
    /\ fastFinalized' = fastFinalized \cup {b}
    /\ finalized' = finalized \cup Ancestors(b)
    /\ notarizedBlocks' = notarizedBlocks \cup Ancestors(b)
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired >>

RegisterFinalCertificate(s, b) ==
    /\ HasFinalCert(s, b)
    /\ ~HasSkipCert(s)  \* Cannot finalize if skip certificate exists
    /\ b \notin finalized
    /\ finalized' = finalized \cup Ancestors(b)
    /\ notarizedBlocks' = notarizedBlocks \cup Ancestors(b)
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired, fastFinalized >>

MarkParentReady(s) ==
    /\ IsFirstInWindow(s)
    /\ ~parentReady[s]
    /\ (s = FirstSlot \/ \E b \in DomainBlocks(s) : Parent(b) \in notarizedBlocks \cup finalized)
    /\ parentReady' = [parentReady EXCEPT ![s] = TRUE]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

ByzantineVoteNotar(n, s, b) ==
    /\ n \in Byzantine
    /\ b \in DomainBlocks(s)
    /\ b \in produced
    /\ notarVotes' = [notarVotes EXCEPT ![s][b] = notarVotes[s][b] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired, finalized, fastFinalized, notarizedBlocks >>

ByzantineSkip(n, s) ==
    /\ n \in Byzantine
    /\ skipVotes' = [skipVotes EXCEPT ![s] = skipVotes[s] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes,
                    skipFallbackVotes, finalVotes, parentReady, timeoutsArmed,
                    timeoutsFired, finalized, fastFinalized, notarizedBlocks >>

ByzantineFallbackNotar(n, s, b) ==
    /\ n \in Byzantine
    /\ notarFallbackVotes' = [notarFallbackVotes EXCEPT ![s][b] = notarFallbackVotes[s][b] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, skipVotes, skipFallbackVotes,
                    finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

ByzantineFallbackSkip(n, s) ==
    /\ n \in Byzantine
    /\ skipFallbackVotes' = [skipFallbackVotes EXCEPT ![s] = skipFallbackVotes[s] \cup {n}]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes,
                    skipVotes, finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

ByzantineFinalize(n, s, b) ==
    /\ n \in Byzantine
    /\ finalVotes' = [finalVotes EXCEPT ![s][n] = b]
    /\ UNCHANGED << produced, delivered, notarVotes, notarFallbackVotes, skipVotes,
                    skipFallbackVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

RotorDissemination(n, b) ==
    /\ n \in Nodes
    /\ b \in produced
    /\ b \notin delivered[n]
    /\ StakeSum({ r \in Nodes : b \in delivered[r] }) >= Stake[n]
    /\ delivered' = [delivered EXCEPT ![n] = delivered[n] \cup {b}]
    /\ UNCHANGED << produced, notarVotes, notarFallbackVotes, skipVotes, skipFallbackVotes,
                    finalVotes, parentReady, timeoutsArmed, timeoutsFired,
                    finalized, fastFinalized, notarizedBlocks >>

ProduceAction == \E s \in Slots : \E b \in DomainBlocks(s) : ProduceBlock(s, b)

ScheduleTimeoutAction == \E s \in Slots : ScheduleTimeout(s)

FireTimeoutAction == \E s \in Slots : FireTimeout(s)

HonestNotarizeAction == \E n \in Honest : \E s \in Slots : \E b \in DomainBlocks(s) : HonestNotarize(n, s, b)

HonestSkipAction == \E n \in Honest : \E s \in Slots : HonestSkip(n, s)

HonestFallbackNotarAction == \E n \in Honest : \E s \in Slots : \E b \in DomainBlocks(s) : HonestFallbackNotar(n, s, b)

HonestFallbackSkipAction == \E n \in Honest : \E s \in Slots : HonestFallbackSkip(n, s)

HonestFinalAction == \E n \in Honest : \E s \in Slots : \E b \in DomainBlocks(s) : HonestFinalVote(n, s, b)

RegisterNotarAction == \E s \in Slots : \E b \in DomainBlocks(s) : RegisterNotarCertificate(s, b)

RegisterFastFinalAction == \E s \in Slots : \E b \in DomainBlocks(s) : RegisterFastFinalCertificate(s, b)

RegisterFinalAction == \E s \in Slots : \E b \in DomainBlocks(s) : RegisterFinalCertificate(s, b)

MarkParentReadyAction == \E s \in Slots : MarkParentReady(s)

ByzantineNotarAction == \E n \in Byzantine : \E s \in Slots : \E b \in DomainBlocks(s) : ByzantineVoteNotar(n, s, b)

ByzantineSkipAction == \E n \in Byzantine : \E s \in Slots : ByzantineSkip(n, s)

ByzantineFallbackNotarAction == \E n \in Byzantine : \E s \in Slots : \E b \in DomainBlocks(s) : ByzantineFallbackNotar(n, s, b)

ByzantineFallbackSkipAction == \E n \in Byzantine : \E s \in Slots : ByzantineFallbackSkip(n, s)

ByzantineFinalAction == \E n \in Byzantine : \E s \in Slots : \E b \in DomainBlocks(s) : ByzantineFinalize(n, s, b)

RotorAction == \E n \in Nodes : \E b \in produced : RotorDissemination(n, b)

Next == 
    ProduceAction
    \/ ScheduleTimeoutAction
    \/ FireTimeoutAction
    \/ HonestNotarizeAction
    \/ HonestSkipAction
    \/ HonestFallbackNotarAction
    \/ HonestFallbackSkipAction
    \/ HonestFinalAction
    \/ RegisterNotarAction
    \/ RegisterFastFinalAction
    \/ RegisterFinalAction
    \/ MarkParentReadyAction
    \/ ByzantineNotarAction
    \/ ByzantineSkipAction
    \/ ByzantineFallbackNotarAction
    \/ ByzantineFallbackSkipAction
    \/ ByzantineFinalAction
    \/ RotorAction

Spec == Init /\ [][Next]_vars

LiveSpec == Spec
    /\ WF_vars(RotorAction)
    /\ WF_vars(HonestNotarizeAction)
    /\ WF_vars(HonestFallbackNotarAction)
    /\ WF_vars(HonestFallbackSkipAction)
    /\ WF_vars(HonestSkipAction)
    /\ WF_vars(MarkParentReadyAction)

(*******************************************************************)
(*                       Invariants & Theorems                     *)
(*******************************************************************)
NoDoubleFinalize == 
    \A s \in Slots : \A b1, b2 \in DomainBlocks(s) :
        (b1 # b2) => ~((b1 \in finalized) /\ (b2 \in finalized))

ChainConsistency == 
    \A b1, b2 \in finalized :
        b1 \in Ancestors(b2) \/ b2 \in Ancestors(b1)

HonestVoteUniqueness ==
    \A n \in Honest : \A s \in Slots :
        Cardinality({ b \in DomainBlocks(s) : n \in notarVotes[s][b] }) <= 1

TypeOK == 
    /\ produced \subseteq BlockIds \cup {GenesisBlock}
    /\ \A n \in Nodes : delivered[n] \subseteq produced
    /\ \A s \in Slots : \A b \in BlockIds : notarVotes[s][b] \subseteq Nodes
    /\ \A s \in Slots : \A b \in BlockIds : notarFallbackVotes[s][b] \subseteq Nodes
    /\ \A s \in Slots : skipVotes[s] \subseteq Nodes
    /\ \A s \in Slots : skipFallbackVotes[s] \subseteq Nodes
    /\ \A s \in Slots : \A n \in Nodes : 
        LET fv == finalVotes[s][n]
        IN (fv = None) \/ (fv = GenesisBlock) \/ (fv \in BlockIds)
    /\ \A s \in Slots : parentReady[s] \in BOOLEAN
    /\ \A s \in Slots : timeoutsArmed[s] \in BOOLEAN
    /\ \A s \in Slots : timeoutsFired[s] \in BOOLEAN
    /\ finalized \subseteq produced
    /\ fastFinalized \subseteq finalized
    /\ notarizedBlocks \subseteq produced

FinalizationImpliesNotar ==
    \A b \in finalized : (b = GenesisBlock) \/ HasNotarCert(SlotOf(b), b)

SkipExcludesFinal ==
    \A s \in Slots : SkipActive(s) => SlotFinalizedBlocks(s) = {}

FastPathUnique ==
    \A s \in Slots : \A b1, b2 \in DomainBlocks(s) :
        b1 # b2 => ~((HasFastFinalCert(s, b1)) /\ (HasFastFinalCert(s, b2)))

THEOREM Spec => []TypeOK

THEOREM Spec => []HonestVoteUniqueness

THEOREM Spec => []NoDoubleFinalize

THEOREM Spec => []ChainConsistency

THEOREM Spec => []FinalizationImpliesNotar

THEOREM Spec => []SkipExcludesFinal

THEOREM Spec => []FastPathUnique

=============================================================================
