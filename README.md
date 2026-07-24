# ProjectBob

A finite-state, rule-based (symbolic AI) dialogue system for Roblox NPCs. Bob doesn't use
machine learning — his conversation logic is a fully deterministic, data-driven finite
state machine (FSM), making his behavior transparent, inspectable, and provably correct
with respect to the specification below.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Formal Specification](#formal-specification)
- [Known Limitations](#known-limitations)
- [Setup](#setup)
- [Extending the Conversation Tree](#extending-the-conversation-tree)
- [License](#license)

## Overview

ProjectBob is an NPC dialogue system built for Roblox Studio. Instead of using a
language model, it represents conversation as an explicit finite state machine: each
state has a scripted prompt, a defined set of valid player responses, and a
deterministic transition to the next state. This is a classic "symbolic AI" approach —
behavior comes from explicit rules and data, not learned weights.

## Architecture

The system has three components, cleanly separated by responsibility:

| Component | Type | Responsibility |
|---|---|---|
| `database` | `ModuleScript` | Pure data — the FSM specification (states, prompts, transitions) |
| `generate` | `Script` (server) | The FSM interpreter — executes transitions, holds per-player state |
| `DialogueClient` | `LocalScript` (client) | Presentation only — renders prompts/options, relays player input |

Conversation state is tracked per player (`conversations[player.UserId]`), so the same
FSM specification runs as an independent instance for every player talking to Bob
simultaneously.

**Data flow per turn:**

```
Player triggers ProximityPrompt
  → generate resets conversation to initial state
  → generate sends current state's prompt to client
  → DialogueClient renders TextBox or choice buttons
Player responds
  → DialogueClient relays response to server
  → generate validates + applies transition, advances state
  → repeat
```

## Formal Specification

*Derived directly from `Database.States`. This section describes the intended
behavior of the FSM as an abstract automaton over an input alphabet; it does not model
the specific client UI, which is only one possible source of that alphabet's symbols
(see [Known Limitations](#known-limitations)).*

### 1. Set of States (S)

```
S = { Greeting, AskFeeling, GoodFollowUp, BadFollowUp,
      Stress, Boredom, Fatigue, Achievement, Friends, "Good weather",
      AnythingElse, Response }
```

### 2. Input Type Classification

```
InputType : S → {"text", "choice", "end"}

InputType(Greeting)       = "text"
InputType(Response)       = "end"
InputType(s)              = "choice"   for all other s ∈ S
```

### 3. Input Domain

```
For text states:
  InputDomain(Greeting, i) ↔ i ∈ FilteredString
  (FilteredString = non-empty strings after Roblox text filtering)

For choice states:
  InputDomain(s, i) ↔ i ∈ Options(s)

For the end state:
  ¬∃i : InputDomain(Response, i)
```

### 4. Options Sets

```
Options(AskFeeling)        = { "Good", "Bad" }
Options(GoodFollowUp)      = { "Achievement", "Friends", "Good weather" }
Options(BadFollowUp)       = { "Stress", "Boredom", "Fatigue" }
Options(Stress)            = { "School", "Work", "Something else" }
Options(Boredom)           = { "Building", "Exploring", "Hanging with friends", "Games" }
Options(Fatigue)           = { "Not really", "It's been fine" }
Options(Achievement)       = { "Built something cool", "Won a match", "Leveled up", "Finished a project" }
Options(Friends)           = { "Just hanging out", "Playing together", "Exploring together" }
Options("Good weather")    = { "Exploring", "Relaxing", "No plans yet" }
Options(AnythingElse)      = { "Yes, let's keep talking", "No, that's all" }
```

### 5. Transition Function

```
Transition(Greeting, i) = AskFeeling                    for any i ∈ FilteredString

Transition(AskFeeling, "Good") = GoodFollowUp
Transition(AskFeeling, "Bad")  = BadFollowUp

Transition(GoodFollowUp, "Achievement")  = Achievement
Transition(GoodFollowUp, "Friends")      = Friends
Transition(GoodFollowUp, "Good weather") = "Good weather"

Transition(BadFollowUp, "Stress")  = Stress
Transition(BadFollowUp, "Boredom") = Boredom
Transition(BadFollowUp, "Fatigue") = Fatigue

For any s ∈ { Stress, Boredom, Fatigue, Achievement, Friends, "Good weather" },
  ∀i ∈ Options(s) : Transition(s, i) = AnythingElse

Transition(AnythingElse, "Yes, let's keep talking") = AskFeeling
Transition(AnythingElse, "No, that's all")          = Response

Response: no outgoing transitions (halting state)
```

### 6. Determinism and Termination

- **Determinism**: for every `s ∈ S` and every `i ∈ InputDomain(s)`, `Transition(s, i)`
  is defined and yields exactly one state. There is no nondeterministic branching.
- **Reachability of a halting state**: `Response` is reachable from every non-`Response`
  state in a bounded number of transitions, and has no outgoing transitions
  (`InputType(Response) = "end"`).
- **Termination is conditional, not unconditional.** The graph contains one designed
  cycle: `AnythingElse → AskFeeling → ... → AnythingElse`. The automaton itself places
  no bound on how many times this cycle may be traversed — a sequence of inputs that
  always selects `"Yes, let's keep talking"` at `AnythingElse` never reaches `Response`.
  Termination therefore holds only under a **fairness assumption on the input
  sequence** (i.e., that `"No, that's all"` is eventually chosen), not as a structural
  property of the automaton alone.

## Known Limitations

- **`InputDomain` is currently a client-side convention, not a server-enforced
  invariant.** The formal spec above defines the accepted alphabet as
  `Options(s)`, but the reference `generate` implementation does not itself validate
  that an incoming input belongs to that set — it relies on the GUI only ever sending
  valid options. Since Roblox clients are not trusted (a modified client can invoke the
  server `RemoteEvent` directly with arbitrary strings), this is a real gap between the
  spec and the deployed system, not just a theoretical one. A conforming implementation
  should reject any input `i ∉ Options(convo.state)` at the server boundary rather than
  processing it. Contributions closing this gap are welcome.
- The formal model only describes the FSM interpreter (`database` + `generate`). The
  client (`DialogueClient`) is treated as an external, untrusted source of input
  symbols and is intentionally out of scope for the automaton definition.
- No persistence layer is currently included — conversation state resets each session.
  (An earlier prototype explored `DataStore`-backed mood tracking with exponential
  decay/habituation; it was intentionally left out of this release pending further
  reliability testing around `DataStore` write guarantees.)

## Setup

1. Create a `ProximityPrompt` on the NPC's `Head` (or another `BasePart`).
2. Add a `ModuleScript` named `database` as a child of the `ProximityPrompt`, containing
   the `Database.States` table.
3. Add a `Script` named `generate` as a child of the `ProximityPrompt`, containing the
   FSM interpreter logic.
4. Create a `RemoteEvent` named `DialogueEvent` inside `ReplicatedStorage`.
5. Add a `LocalScript` named `DialogueClient` inside `StarterPlayerScripts` to render
   the dialogue UI and relay player input.

## Extending the Conversation Tree

Because the FSM is pure data, adding new branches only requires editing `database` —
no changes to `generate` are needed. To add a new state:

1. Add an entry to `Database.States` with a `prompt`, `inputType`, `options` (if
   `choice`), and `nextState`.
2. Point some existing state's `nextState` at your new state's key (directly, or via a
   branch table keyed by option).

## License

*MIT License* See LICENSE for further details.

## AI Usage Note
*Claude (Sonnet 5)*
AI models have been used for assisting with code generation and documentation.
Conversation design, project direction, and the formal specification approach
are the author's own.
