# Sticky charge polish — published v254

Original place **94763223427049**, branch `planning/development-foundation`. Approved charge geometry/materials, tools, creature integration, environment, UI layout, owner Test Mode and player saves are preserved. Studio is stopped in Edit. No owner approval of this corrected pose is claimed.

## Defects and corrections

**Hold:** the charge inherited the pickaxe idle arm pose. The first bent-elbow check exposed a second issue: the old grip orientation made the assembly lie horizontally as the forearm lifted. A charge-only relaxed elbow/neutral-wrist pose and compensated grip now keep the assembly upright, with the palm at the side/rear strap. The placement gesture lasts 0.32 seconds rather than stretching across the fuse. Existing switch, unequip and character lifecycle cleanup is retained; no IK rewrite or avatar changes.

**Preview:** `Targeting` unparented and reparented the same model on every RenderStepped callback. Its surface frame also switched its up-axis abruptly when normal.Y crossed the old 0.94 threshold, producing a roll discontinuity. The preview now stays parented while visible, and both preview and server placement use one continuous upright surface frame and the measured rear plate with the existing **0.012-stud clearance**. One preview instance is reused; no competing renderer was found. Parts were already non-queryable, so a self-hit was not established as the cause; explicit shared ray filters now exclude the character/held tool, preview and placed-charge folder as well.

The translucent asset keeps its recognizable colors with a restrained invalid tint. It has no collision, shadows, active screen or fuse. The redundant shell outline/precision marker is suppressed for the charge. Submission hides it immediately; accepted placement, cancellation, switching and target loss also hide it. After Cancel, moving the aim or making a new placement request resumes the preview.

**Fuse:** shared `ExcavationConfig.Tools.Explosive.Fuse` is intentionally **3.0 seconds**, replacing 0.45. One server deadline drives charge removal/detonation and client presentation. The timer reads **3 → 2 → 1 → 0**; zero is shown during the final 0.12-second warning. A small warm ember travels down sampled centers of the original modeled rope, with small sparks, light smoke and a restrained final pulse. No source geometry or texture edits.

The pending-placement guard prevents stacking even when upgrade cooldown is shorter than the fuse. Cancellation tokens invalidate old callbacks. Other tools retain their original windup scheduling. Damage, radius, seven-section cap, falloff, costs, upgrade/cooldown values and rewards are unchanged.

Audio uses the existing SFXVolume and spatial rolloff settings: [Match Stick / MFG_WLAN](https://create.roblox.com/store/asset/121468423287955) for a short ignition and [Countdown beep / santt2848](https://create.roblox.com/store/asset/117751546358455) for ticks. Both were available free on Creator Store and inserted successfully.

## Actual verification

One **263-second Studio memory-only session**, including the concrete grip correction and capture preparation. No real profile was used or written.

- Actual owner's R15 avatar: held grip, switch to pickaxe and unequip checked. Bulky sleeves obscure some fingers; screenshots are for owner review.
- Moving aim: one preview remained visible for an observed 821 frames with **zero parent changes** at that checkpoint. No active countdown/fuse on the ghost. Accepted placement matched its shared frame.
- Exactly **one complete detonation**. The observer recorded 3/2/1/0, burning effect, both sounds loaded/playing, and approximately 3.00 seconds from observed acceptance to Blast. Two later accepted placements were canceled via F and tool switch; all three visuals were removed. No charge/ghost remained after cleanup.
- Edit normal sweep verified rear contact and continuity across the former flip threshold. Ten final canonical sources match Studio; formatting checks pass. Runtime Output contained only the normal rooms-ready message. Helpers and temporary platform are absent.

Limitations: respawn, R6/other avatar sizes, multiplayer latency and published-client play were not runtime-tested. Audio playback was observed programmatically; the audible mix was not reviewed. The video is **silent**. The earlier creature texture-pack limitation remains outside this charge-only task.

## Actual evidence

- [In hand](in-hand.png)
- [Moving placement preview](placement-preview.png)
- [Accepted placement, countdown and active fuse](placed-countdown.png)
- [7.5-second actual aiming → placement → full countdown → detonation clip](runtime-countdown.mp4)

The clip uses actual desktop captures held until their next recorded timestamp, with no interpolation or time compression. [Clip timing](clip-timing.json), [runtime observations](runtime-observations.json), [delivery/backup identity](delivery.json). Use a fresh **v254** server; occupied servers were not shut down.
