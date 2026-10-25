<!--
SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>

SPDX-License-Identifier: GPL-3.0-or-later
-->

# jellyfin-plugin-snatcharr

A Jellyfin server plugin that connects Jellyfin to [SnatchArr](https://github.com/lusoris/SnatchArr): adult scene metadata, image-set galleries and request routing. The name joins "Jellyfin plugin" with "SnatchArr" (said "snatch-ar"), the application the plugin talks to.

The design is [ADR-0028](https://github.com/lusoris/SnatchArr/blob/main/docs/adr/0028-jellyfin-plugin.md) in the SnatchArr repository. The plugin code is not written yet.

## Licence

This repository is licensed GPL-3.0-or-later (see [LICENSE](LICENSE)). The licence covers the plugin code and everything written for this repository.

- **Why GPL:** the plugin loads into the Jellyfin server and links against its GPL-licensed assemblies, so the plugin and Jellyfin form one combined work. GPL-3.0-or-later is also the licence of [jellyfin/jellyfin-plugin-template](https://github.com/jellyfin/jellyfin-plugin-template), whose notice this repository carries.
- **Why it differs from SnatchArr:** SnatchArr itself is EUPL-1.2. The plugin's licence was chosen once, on 2026-10-24, because of the Jellyfin linkage. It is a permanent choice, not a temporary exception.
- **Copied tooling:** the CI, scanner and commit-message files copied from SnatchArr keep their EUPL-1.2 licence. [REUSE.toml](REUSE.toml) and each file's header say which licence applies, and `reuse lint` checks this on every pull request.

## Plugin identity

The plugin GUID is `040a8e66-1be2-4e9b-befb-89a889fdb229`. It was generated once when this repository was created and never changes: Jellyfin uses it to tell installed plugins apart and to match catalog updates.

## Credits

The `LICENSE` text comes from [jellyfin/jellyfin-plugin-template](https://github.com/jellyfin/jellyfin-plugin-template) at commit `c93225a0` (GPL-3.0, by the Jellyfin contributors); the plugin code will follow that template's layout.

The CI, scanner and commit-message tooling is copied from [lusoris/SnatchArr](https://github.com/lusoris/SnatchArr) at commit `86dc3376` and keeps its EUPL-1.2 licence (same author; see [REUSE.toml](REUSE.toml) and the headers of each file). `LICENSES/` holds both licence texts.

<!-- praetor:readme-governance:start -->
[![HISS Adopted][praetor-hiss-badge]][praetor-hiss-agents]

Praetor manages this repository's declared governance policy. This managed
block records adoption state; it is not a verification certificate.

**Verification**: `make verify-all` runs the repository's configured
verification cascade.

**HISS Audit**: `praetorctl audit` enforces policy, generated-surface
integrity, and the debt ratchet.

**Context Sync**: `praetorctl compile-context --verify` verifies every
generated agent context against `AGENTS.md`.

**Debt Baseline**: `.standards-baseline.json` anchors the debt ratchet at
1 recorded infraction; audit forbids growth.

[praetor-hiss-badge]: https://img.shields.io/badge/Standards-HISS%20Adopted%20(1%20baselined)-yellow
[praetor-hiss-agents]: https://github.com/lusoris/jellyfin-plugin-snatcharr/blob/HEAD/AGENTS.md
<!-- praetor:readme-governance:end -->
