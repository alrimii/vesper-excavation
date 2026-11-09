# Project execution rules

## Authority and scope
Communicate exclusively in English unless the user explicitly requests otherwise.
Phase 1B retains provisional acceptance. Phase 4B implementation has been reviewed; prior gameplay, device, audio and persistence checks remain unverified. Current authorization is Phase 5A: a focused written progression, genuine skill-tree and rebirth specification in docs/PHASE_5A_PROGRESSION_SPEC.md, plus brief roadmap/instruction references. Inspect relevant code read-only and commit/push documentation only. Do not modify runtime scripts, Studio assets, player data or the published experience. No images, concept boards, animations, installs, reset/migration, grants or redeem-code implementation. Proposed numeric rules and abilities are not implemented or approved balance. Stop for user approval before Phase 5B. Original place 94763223427049 remains the sole future implementation target; a fresh native recovery backup is required before later implementation, not for this documentation-only phase. Existing untransferred claims remain same-server memory and do not survive shutdown.
Both reinforced and fire upgrade studies are rejected for production. Preserve historical files; no concepts, alternate designs, Blender presentations, GIFs or videos. Use existing models and progression structure. No runtime implementation of additional families, levels, skill trees, fire mechanics, currencies, rebirth, trophies, worlds, purchases or creature content in Phase 5A; progression design is authorized only in the specification. Keep Phase 3 blast radius/falloff/target cap. No egg architecture rewrite or replacement opening cinematic. Later phases still require approval.
Roadmap only: user requests a future one-time reset of all published player progress without retention/migration, and reusable public redeem codes plus a 100,000,000-credit testing code restricted to explicitly authorized tester UserIds. No reset, DataStore manipulation, grants or redemption implementation is authorized in Phase 5A. The user reports manually publishing the latest update; do not assume production is still on an older version. Development recovery backups are not player-progress backups or migration plans.
Current menus/HUD are functional interim UI, not approved final visual quality. Dedicated illustrated equipment/upgrade screens and a genuine navigable skill tree with connected nodes, branches, prerequisites and locked/available/unlocked states require their own scoped design and implementation phase. A text upgrade list does not meet that requirement. Phase 5A specifies the tree layout and art assets in writing; it does not produce UI art or authorize that redesign in Studio.
Preserve useful systems. Historical completion reports are leads, not acceptance evidence. Do not rewrite the project by default.

## Execution restrictions
The user performs gameplay testing in Studio. Without an explicit exception:
- Never start or stop Play, Run, or Playtest, run automated tests/suites, simulations, synthetic players, keyboard/mouse automation, or character navigation.
- Never trigger diagnostic execution; reading existing diagnostics, source comparison and code review are allowed.
- Never grant currency, unlock equipment, modify saves or production data for testing, or publish to Roblox.
- Never install/update tools, MCP servers, plugins or external skills, change global settings, or edit shared skills.
- Do not bypass restrictions through scripts, alternate tools or agents. Do not delegate unless explicitly requested.
- If Studio is running, leave it running; continue independent read-only work and identify work requiring Edit mode.
Never claim tested, performant, glitch-free or visually approved without evidence. Tool descriptions suggesting starting/stopping play do not override these rules.
Retained native-backup exception: narrowly scoped Studio UI automation is authorized solely to save a full native place recovery copy. It does not permit gameplay input, Play/Run or testing. No concept or animated previews in Phase 5A.

## Single implementation target
The existing original Studio place (Coming Soon, place ID 94763223427049) is the sole implementation target. Never create a separate test/development place, staging world, duplicated map or parallel playable implementation for later transfer.
Backups are recovery copies only; never open them as development targets. When implementation is approved, edit the original place's actual assets and systems directly, with scoped recoverable changes. The user manually playtests that same place.
Keep repository source and editable assets synchronized with the actual implementation. Historical concept studies must not become a second playable environment. This workflow does not authorize publishing, tests or advancement beyond the approved phase.

## Preservation and synchronization
Inspect Git status and intended Studio place/mode before changes. Preserve unrelated and ignored work. Never reset, clean, force-push, merge into main, or restore a snapshot over the open place.
Use a dedicated branch. Stage explicit phase files only. Keep credentials, authentication files, tools/caches and private local backups out of Git.
The flat src directory mixes runtime code and historical builders. Use the live path inventory in docs/CURRENT_STATE.md and verify exact paths before synchronizing. Never execute all builders, installers or restore recipes.
Prefer the existing Studio integration and verified Blender/BlendRelay workflow. Source files, editable assets, exports and metadata must be saved; Git alone does not preserve unsaved Studio state or hosted asset bytes.

## Quality and delivery
Follow docs/GAME_VISION.md, docs/ART_DIRECTION.md and docs/DEVELOPMENT_PLAN.md. New effects, prices and unresolved mechanics require decisions before implementation.
For each authorized phase, prepare Studio for manual review, save code/editable assets, push Git changes, and deliver branch, SHA, commit link, changes, incomplete work, concise manual actions and explicit untested areas using docs/REVIEW_HANDOFF.md.
Wait for feedback and approval before the next phase; address review feedback within the current phase.
Blender previews are asset delivery, not permission to run gameplay tests. A concept image is not a 3D asset; a render is not proof of Roblox appearance.
