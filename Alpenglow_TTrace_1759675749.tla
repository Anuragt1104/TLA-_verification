---- MODULE Alpenglow_TTrace_1759675749 ----
EXTENDS Sequences, TLCExt, Alpenglow_TEConstants, Toolbox, Naturals, TLC, Alpenglow

_expression ==
    LET Alpenglow_TEExpression == INSTANCE Alpenglow_TEExpression
    IN Alpenglow_TEExpression!expression
----

_trace ==
    LET Alpenglow_TETrace == INSTANCE Alpenglow_TETrace
    IN Alpenglow_TETrace!trace
----

_inv ==
    ~(
        TLCGet("level") = Len(_TETrace)
        /\
        notarFallbackVotes = ((0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})))
        /\
        delivered = ((n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}))
        /\
        timeoutsArmed = ((0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE))
        /\
        produced = ({[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]})
        /\
        finalized = ({[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]})
        /\
        skipVotes = ((0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}))
        /\
        skipFallbackVotes = ((0 :> {n1} @@ 1 :> {} @@ 2 :> {}))
        /\
        notarizedBlocks = ({[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]})
        /\
        fastFinalized = ({})
        /\
        timeoutsFired = ((0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE))
        /\
        notarVotes = ((0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})))
        /\
        parentReady = ((0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE))
        /\
        finalVotes = ((0 :> (n1 :> [slot |-> 0, tag |-> "A"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> 0, tag |-> "A"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"])))
    )
----

_init ==
    /\ notarizedBlocks = _TETrace[1].notarizedBlocks
    /\ skipFallbackVotes = _TETrace[1].skipFallbackVotes
    /\ delivered = _TETrace[1].delivered
    /\ fastFinalized = _TETrace[1].fastFinalized
    /\ skipVotes = _TETrace[1].skipVotes
    /\ notarVotes = _TETrace[1].notarVotes
    /\ finalVotes = _TETrace[1].finalVotes
    /\ timeoutsFired = _TETrace[1].timeoutsFired
    /\ timeoutsArmed = _TETrace[1].timeoutsArmed
    /\ parentReady = _TETrace[1].parentReady
    /\ finalized = _TETrace[1].finalized
    /\ notarFallbackVotes = _TETrace[1].notarFallbackVotes
    /\ produced = _TETrace[1].produced
----

_next ==
    /\ \E i,j \in DOMAIN _TETrace:
        /\ \/ /\ j = i + 1
              /\ i = TLCGet("level")
        /\ notarizedBlocks  = _TETrace[i].notarizedBlocks
        /\ notarizedBlocks' = _TETrace[j].notarizedBlocks
        /\ skipFallbackVotes  = _TETrace[i].skipFallbackVotes
        /\ skipFallbackVotes' = _TETrace[j].skipFallbackVotes
        /\ delivered  = _TETrace[i].delivered
        /\ delivered' = _TETrace[j].delivered
        /\ fastFinalized  = _TETrace[i].fastFinalized
        /\ fastFinalized' = _TETrace[j].fastFinalized
        /\ skipVotes  = _TETrace[i].skipVotes
        /\ skipVotes' = _TETrace[j].skipVotes
        /\ notarVotes  = _TETrace[i].notarVotes
        /\ notarVotes' = _TETrace[j].notarVotes
        /\ finalVotes  = _TETrace[i].finalVotes
        /\ finalVotes' = _TETrace[j].finalVotes
        /\ timeoutsFired  = _TETrace[i].timeoutsFired
        /\ timeoutsFired' = _TETrace[j].timeoutsFired
        /\ timeoutsArmed  = _TETrace[i].timeoutsArmed
        /\ timeoutsArmed' = _TETrace[j].timeoutsArmed
        /\ parentReady  = _TETrace[i].parentReady
        /\ parentReady' = _TETrace[j].parentReady
        /\ finalized  = _TETrace[i].finalized
        /\ finalized' = _TETrace[j].finalized
        /\ notarFallbackVotes  = _TETrace[i].notarFallbackVotes
        /\ notarFallbackVotes' = _TETrace[j].notarFallbackVotes
        /\ produced  = _TETrace[i].produced
        /\ produced' = _TETrace[j].produced

\* Uncomment the ASSUME below to write the states of the error trace
\* to the given file in Json format. Note that you can pass any tuple
\* to `JsonSerialize`. For example, a sub-sequence of _TETrace.
    \* ASSUME
    \*     LET J == INSTANCE Json
    \*         IN J!JsonSerialize("Alpenglow_TTrace_1759675749.json", _TETrace)

=============================================================================

 Note that you can extract this module `Alpenglow_TEExpression`
  to a dedicated file to reuse `expression` (the module in the 
  dedicated `Alpenglow_TEExpression.tla` file takes precedence 
  over the module `Alpenglow_TEExpression` below).

---- MODULE Alpenglow_TEExpression ----
EXTENDS Sequences, TLCExt, Alpenglow_TEConstants, Toolbox, Naturals, TLC, Alpenglow

expression == 
    [
        \* To hide variables of the `Alpenglow` spec from the error trace,
        \* remove the variables below.  The trace will be written in the order
        \* of the fields of this record.
        notarizedBlocks |-> notarizedBlocks
        ,skipFallbackVotes |-> skipFallbackVotes
        ,delivered |-> delivered
        ,fastFinalized |-> fastFinalized
        ,skipVotes |-> skipVotes
        ,notarVotes |-> notarVotes
        ,finalVotes |-> finalVotes
        ,timeoutsFired |-> timeoutsFired
        ,timeoutsArmed |-> timeoutsArmed
        ,parentReady |-> parentReady
        ,finalized |-> finalized
        ,notarFallbackVotes |-> notarFallbackVotes
        ,produced |-> produced
        
        \* Put additional constant-, state-, and action-level expressions here:
        \* ,_stateNumber |-> _TEPosition
        \* ,_notarizedBlocksUnchanged |-> notarizedBlocks = notarizedBlocks'
        
        \* Format the `notarizedBlocks` variable as Json value.
        \* ,_notarizedBlocksJson |->
        \*     LET J == INSTANCE Json
        \*     IN J!ToJson(notarizedBlocks)
        
        \* Lastly, you may build expressions over arbitrary sets of states by
        \* leveraging the _TETrace operator.  For example, this is how to
        \* count the number of times a spec variable changed up to the current
        \* state in the trace.
        \* ,_notarizedBlocksModCount |->
        \*     LET F[s \in DOMAIN _TETrace] ==
        \*         IF s = 1 THEN 0
        \*         ELSE IF _TETrace[s].notarizedBlocks # _TETrace[s-1].notarizedBlocks
        \*             THEN 1 + F[s-1] ELSE F[s-1]
        \*     IN F[_TEPosition - 1]
    ]

=============================================================================



Parsing and semantic processing can take forever if the trace below is long.
 In this case, it is advised to uncomment the module below to deserialize the
 trace from a generated binary file.

\*
\*---- MODULE Alpenglow_TETrace ----
\*EXTENDS IOUtils, Alpenglow_TEConstants, TLC, Alpenglow
\*
\*trace == IODeserialize("Alpenglow_TTrace_1759675749.bin", TRUE)
\*
\*=============================================================================
\*

---- MODULE Alpenglow_TETrace ----
EXTENDS Alpenglow_TEConstants, TLC, Alpenglow

trace == 
    <<
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> FALSE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> 0, tag |-> "A"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> 0, tag |-> "A"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> 0, tag |-> "A"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> 0, tag |-> "A"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> 0, tag |-> "A"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))]),
    ([notarFallbackVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),delivered |-> (n1 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n2 :> {[slot |-> -1, tag |-> "G"]} @@ n3 :> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]} @@ n4 :> {[slot |-> -1, tag |-> "G"]}),timeoutsArmed |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),produced |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},finalized |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},skipVotes |-> (0 :> {n2, n4} @@ 1 :> {} @@ 2 :> {}),skipFallbackVotes |-> (0 :> {n1} @@ 1 :> {} @@ 2 :> {}),notarizedBlocks |-> {[slot |-> -1, tag |-> "G"], [slot |-> 0, tag |-> "A"]},fastFinalized |-> {},timeoutsFired |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),notarVotes |-> (0 :> ([slot |-> 0, tag |-> "A"] :> {n1, n3, n4} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 1 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {}) @@ 2 :> ([slot |-> 0, tag |-> "A"] :> {} @@ [slot |-> 1, tag |-> "A"] :> {} @@ [slot |-> 2, tag |-> "A"] :> {})),parentReady |-> (0 :> TRUE @@ 1 :> FALSE @@ 2 :> FALSE),finalVotes |-> (0 :> (n1 :> [slot |-> 0, tag |-> "A"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> 0, tag |-> "A"] @@ n4 :> [slot |-> 0, tag |-> "A"]) @@ 1 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]) @@ 2 :> (n1 :> [slot |-> -2, tag |-> "NONE"] @@ n2 :> [slot |-> -2, tag |-> "NONE"] @@ n3 :> [slot |-> -2, tag |-> "NONE"] @@ n4 :> [slot |-> -2, tag |-> "NONE"]))])
    >>
----


=============================================================================

---- MODULE Alpenglow_TEConstants ----
EXTENDS Alpenglow

CONSTANTS n1, n2, n3, n4

=============================================================================

---- CONFIG Alpenglow_TTrace_1759675749 ----
CONSTANTS
    Nodes = { n1 , n2 , n3 , n4 }
    Honest = { n1 , n2 , n3 }
    Byzantine = { n4 }
    Slots = { 0 , 1 , 2 }
    WindowSize = 2
    ThresholdFast = 80
    ThresholdSlow = 60
    ThresholdFallback = 20
    DeltaFast = 1
    DeltaSlow = 2
    n4 = n4
    n2 = n2
    n3 = n3
    n1 = n1

INVARIANT
    _inv

CHECK_DEADLOCK
    \* CHECK_DEADLOCK off because of PROPERTY or INVARIANT above.
    FALSE

INIT
    _init

NEXT
    _next

CONSTANT
    _TETrace <- _trace

ALIAS
    _expression
=============================================================================
\* Generated on Sun Oct 05 20:50:27 IST 2025