# Agent tooling assets

Status: operational note  
Last reviewed: 2026-08-01

The repository currently contains tool-managed skill directories in both applications. Their consuming installer is not declared in project scripts, and the Flutter project also contains a divergent `agent/skills` copy.

These files are intentionally left unchanged until the owning tool is confirmed. Removing or relocating them could silently break external IDE integrations. When ownership is known, keep one canonical root source plus one lock file and generate any tool-specific mirrors; do not hand-edit multiple copies.
