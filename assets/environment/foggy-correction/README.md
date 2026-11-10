# Focused source-conversion correction

Only our authoring code is stored here. It references the unchanged private Foggy Gazebo download and previous private conversion; it cannot reconstruct restricted source assets from this repository alone.

- `authoring/bake.py`: excludes the non-foliage gradient Plane.301, retains source materials/fog, and renders corrected far-field views. These remain **unsuccessful as the final backdrop**.
- `authoring/geometry.py`: preserves smooth leaf/wood normals and source alpha UVs, corrects the terrain profile and approach contact, and exports two continuous background halves. The background halves are retained as unused native templates.
- `authoring/project_texture.py`: perspective-aware cylindrical projection and source-sky rejection. Its silhouette result was not visually sufficient and is not displayed. A later private diagnostic version multiplied color difference from `(201,222,225)` by 1.6; it also failed the atmosphere goal and is unused.
- The displayed 512px leaf map retains the prior source alpha with RGB `(64,118,91)`, asset `137012180294436`. Source alpha and maps remain private.

[Review, screenshots, exact asset IDs and unresolved limitations](../../../docs/reviews/foggy-correction/REVIEW.md). [Current inventory](../../../docs/reviews/foggy-correction/asset-inventory.json). Restricted source, editable Blender derivative, FBX and image exports are under `Backups/FoggyCorrection_20261110/`. The unresolved Blendkit/Maxtree constituent rights have not been cleared.
