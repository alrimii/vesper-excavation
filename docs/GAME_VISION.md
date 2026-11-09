# Game vision
Status: Phase 0 planning, 9 November 2026. The project name and final art style are not finalized. This document governs future direction; it does not claim current implementation.

## Confirmed requirements
The central loop is cooperative destruction of a giant laboratory egg, automatic material collection, selling, meaningful equipment progression and rare creature discovery. Preserve useful rooms, training, progression and collection systems.
Breaking the egg must itself feel satisfying. Stronger or different actions, evolving equipment, clear feedback and desirable unlocks must connect short-term rewards to long-term achievements. Avoid tedious repetition as the main retention mechanism.
Polish includes coherent Roblox interfaces, readable feedback, animation, rewards and movement. Flicker, overlapping surfaces, awkward movement and poor tool handling are acceptance problems even when code reports no errors.

### Shared egg lifecycle
An egg is an ongoing server-wide activity. Joining players inherit the current egg/progress without resetting it or replaying the introduction for everyone. A newly initialized server may show selection/delivery once. Completion triggers hatch/reveal/results, then selection and delivery of the next egg without unnecessary idle time. Timings and durations remain open.

### Tools
Distinct families should have meaningful differences in behavior, animation, sound and appearance. Candidate families include pickaxes, drills, heavy two-handed drilling equipment and explosive charges.
Define family, tier, upgrade choices and special effects separately before implementation. Show tradeoffs whenever a new purchase performs worse in some respect than current equipment; never silently sell a regression as superiority.

### Eggs and creatures
Major themes need recognizable silhouettes, shell construction, materials/textures, cracks/destruction effects, sound, reveal, gameplay characteristics and creature rewards. Ice and infernal/volcanic eggs are directions, not finalized assets. Recolors alone are insufficient.
Rarity is deliberate; low drop rates are not automatic grounds to increase them. Desired direction: contribution-aware personal eligibility, potentially multiple creature recipients per egg. Meaningful participation, support, newcomers and late arrivals must be considered; avoid dominant last-hit or near-completion joining strategies.

### Training
Optional, straightforward training must not gate mining. Progress should be noticeable through concise gains, readable indicators and milestone effects.

### Rebirth and worlds
Rebirth resets level/current XP and only specifically designated resettable personal upgrades. It preserves owned tools/weapons and their upgrades, permanent acquired buffs, creatures, cosmetics, trophies, achievements and unlocked worlds.
It grants a permanent benefit that accelerates rebuilding levels. Show resettable upgrades and permanent benefits separately before confirmation. Temporary buffs must never become permanent through rebirth.
Future worlds preserve accomplishments while adding their own eggs, weapons, creatures and harder gameplay.

## Proposals to evaluate, not approved mechanics
- Visibly evolving pickaxes, including diamond equipment; drills evolving into substantial two-handed machines.
- Explosives with deliberate fuse/timing and neighboring-section radius damage; tool-specific upgrade trees; chain lightning spreading to adjacent sections. Other effects require separate approval.
- Passive mastery through real play; it is not an approved wholesale replacement for training.
- Different training equipment appearances and possible paid variants.
- Achievements for meaningful participation in multiple completions, with more valuable difficult/rare egg rewards.
- A solo-completion achievement with an avatar statue in the room and distinctive aura.
- Trophies as progression/customization currency; separate lifetime total and spendable balance.
- Character/tool auras, effects, titles, room decoration and creature displays; modest customization buffs.
- Permanent XP gain as a rebirth benefit, without approved numerical values.
- Clearly described multipliers, earned-currency equipment with possible Robux alternatives, training purchases, cosmetics and early Robux rebirth.

## Unresolved decisions
Contribution formula/eligibility, support credit, newcomer and late-arrival handling, multi-recipient rewards; solo definition; trophy amounts, thresholds and buff limits; tool family/tier/upgrade/effect relationships; training benefits; rebirth requirements, multipliers, caps and currency resets; world unlock requirements (level 200 was only an example); egg durations and transition timing; all purchase benefits/prices/product IDs.
Before monetization, assess contribution fairness, progression, repeat rebirth and purchases related to randomized rewards, and verify current Roblox requirements then. Phase 0 assigns no prices/IDs and implements no purchases.
