# Phase 5 interface assets

`field-icons.png` is a 640 × 512 transparent atlas of twenty Game-icons.net icons, each resized to 112 pixels inside a 128-pixel cell. Runtime tint supplies the shared mineral/parchment palette. Exact source URLs, authors, license URLs, source SHA256 values and cell coordinates are in [sources.json](sources.json); original downloaded PNGs are in `source/`, and [build_icons.py](build_icons.py) rebuilds the atlas.

Icons by **Lorc, Delapouite, Skoll and Faithtoken**, from [Game-icons.net](https://game-icons.net/), licensed under [Creative Commons Attribution 3.0](https://creativecommons.org/licenses/by/3.0/). Changes: resizing, transparent padding, atlas packing and runtime color tint. Attribution also appears in the game's settings. Free download is not a claim of unrestricted rights; attribution is required. No replacement is required by the recorded license, unlike earlier interim assets in their own ledgers.

Distinct tool artwork: Lorc's Mining, Delapouite's Drill and Dynamite. Other icons cover journal, compass/navigation, equipment, settings, skills, storage, research, creatures, room, sound, motion, results, credits, speed, precision, ore/yield and sale value.

Roblox image **121599750729304**, owner **291892217**, operation **a573d273-8518-4697-bd92-5979e02b66df**: [actual upload record](upload.json). The atlas rendered in the recorded Studio session. The approved upload directory was saved through Studio's supported permissions UI; files were not moved to bypass the allowlist.

The interface reuses existing `SkillArt` illustrations, existing egg portraits and the Phase 4 `EquipmentAssets` models. No concept image is presented as game evidence.

Canonical generation: `src/InterfaceTheme.luau`, `src/InterfaceKit.luau`, `src/ExcavationUI.luau` plus the replaced current view modules. `cleanup.luau` records the one-time explicit removal of superseded UI instances; it is not a startup builder.
