; (C) CC-BY Irfansha Shaik, Jaco van de Pol, Aarhus University, 2023

; Planning Domain for Optimal Quantum Layout Mapping (lifted version)
; - initial mapping is integrated in the first CNOT
; - ancillary swaps are excluded in this version
; - this version is simplified, assuming STRICT dependencies

(define (domain quantum)

(:requirements :strips :typing :negative-preconditions)

(:types 
    pbit - object   ; physical qubit
    gate - object   ; gate (binary gate or input gate)
    lbit - object)  ; logical qubit

(:predicates
    ; logical qubit ?l is currently mapped on physical qubit ?p
    (mapped ?l - lbit ?p - pbit)

    ; physical qubit ?p is occupied
    (occupied ?p - pbit)                        

    ; physical qubits ?p1 and ?p2 are connected;
    ; static predicate
    (connected ?p1 ?p2 - pbit)                 

    ; gate ?g0 on logical qubits ?l1 and ?l2 depends on gates ?g1 and ?g2
    ; static predicate
    (cnot ?l1 ?l2 - lbit ?g0 ?g1 ?g2 - gate)   

    ; gate ?g has been applied
    ; initially all false, goal is to get them all true
    (done ?g - gate)         
    
    (ready)                                       
)

(:action apply_cnot_gate_gate
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 - pbit ?g0 ?g1 ?g2 - gate)
    :precondition (and
        (cnot ?l1 ?l2 ?g0 ?g1 ?g2)
        (connected ?p1 ?p2)
        (mapped ?l1 ?p1) (mapped ?l2 ?p2)
        (done ?g1) (done ?g2) (not (done ?g0))
    )
    :effect (and
        (done ?g0)
    )
)

(:action apply_cnot_input_input
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 - pbit ?g0 - gate)
    :precondition (and
        (cnot ?l1 ?l2 ?g0 ?l1 ?l2)
        (connected ?p1 ?p2)
        (not (occupied ?p1)) (not (occupied ?p2))
        (not (done ?g0))
    )
    :effect (and
        (done ?g0)
        (mapped ?l1 ?p1) (occupied ?p1)
        (mapped ?l2 ?p2) (occupied ?p2)
    )
)

(:action apply_cnot_input_gate
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 - pbit ?g0 ?g2 - gate)
    :precondition (and
        (cnot ?l1 ?l2 ?g0 ?l1 ?g2)
        (connected ?p1 ?p2)
        (mapped ?l2 ?p2)
        (not (occupied ?p1))
        (done ?g2) (not (done ?g0))
    )
    :effect (and
        (done ?g0)
        (mapped ?l1 ?p1) (occupied ?p1)
    )
)

(:action apply_cnot_gate_input
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 - pbit ?g0 ?g1 - gate)
    :precondition (and
        (cnot ?l1 ?l2 ?g0 ?g1 ?l2)
        (connected ?p1 ?p2)
        (mapped ?l1 ?p1)
        (not (occupied ?p2))
        (done ?g1) (not (done ?g0))
    )
    :effect (and
        (done ?g0)
        (mapped ?l2 ?p2) (occupied ?p2)
    )
)

(:action bridge
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 ?p3 - pbit ?g0 ?g1 ?g2 - gate)
    :precondition (and
        (ready)
        (cnot ?l1 ?l2 ?g0 ?g1 ?g2) 
        (connected ?p1 ?p2) (connected ?p2 ?p3) (not (connected ?p1 ?p3))
        (mapped ?l1 ?p1) (mapped ?l2 ?p3)
        (done ?g1) (done ?g2) (not (done ?g0))
    )
    :effect (and
        (done ?g0) (not (ready))
    )
)
(:action dummy 
    :parameters ()
    :precondition (not (ready))
    :effect (ready)

)

(:action swap
    :parameters (?l1 ?l2 - lbit ?p1 ?p2 - pbit)
    :precondition (and 
        (connected ?p1 ?p2)
        (mapped ?l1 ?p1) (mapped ?l2 ?p2)
    )
    :effect (and 
        (mapped ?l1 ?p2) (not (mapped ?l1 ?p1))
        (mapped ?l2 ?p1) (not (mapped ?l2 ?p2))
    )
)

)
