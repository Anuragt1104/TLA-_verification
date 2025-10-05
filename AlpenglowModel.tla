---- MODULE AlpenglowModel ----
EXTENDS Naturals

n1 == "n1"
n2 == "n2"
n3 == "n3"
n4 == "n4"

LeaderFunc == [0 |-> n1, 1 |-> n2, 2 |-> n3]
StakeFunc == [n1 |-> 30, n2 |-> 30, n3 |-> 20, n4 |-> 20]
GenesisBlockVal == [slot |-> -1, tag |-> "G"]
BlockOptionsFunc == [
    0 |-> {[slot |-> 0, tag |-> "A"], [slot |-> 0, tag |-> "B"]},
    1 |-> {[slot |-> 1, tag |-> "A"], [slot |-> 1, tag |-> "B"]},
    2 |-> {[slot |-> 2, tag |-> "A"], [slot |-> 2, tag |-> "B"]}
]
ParentOfFunc == [
    [slot |-> -1, tag |-> "G"] |-> [slot |-> -1, tag |-> "G"],
    [slot |-> 0, tag |-> "A"] |-> [slot |-> -1, tag |-> "G"],
    [slot |-> 0, tag |-> "B"] |-> [slot |-> -1, tag |-> "G"],
    [slot |-> 1, tag |-> "A"] |-> [slot |-> 0, tag |-> "A"],
    [slot |-> 1, tag |-> "B"] |-> [slot |-> 0, tag |-> "A"],
    [slot |-> 2, tag |-> "A"] |-> [slot |-> 1, tag |-> "A"],
    [slot |-> 2, tag |-> "B"] |-> [slot |-> 1, tag |-> "A"]
]

====

