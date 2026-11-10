# STATE__entity-lifecycle

Optional. State diagrams are for entities with an important lifecycle or a risk of illegal transitions.

```mermaid
stateDiagram-v2
    state "Initial" as S0
    state "Next" as S1
    [*] --> S0
    S0 --> S1: "trigger"
    S1 --> [*]
```

Key transition conditions or forbidden transitions (if needed): …
