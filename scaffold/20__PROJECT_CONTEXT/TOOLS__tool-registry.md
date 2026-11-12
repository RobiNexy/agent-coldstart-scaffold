# TOOLS__tool-registry

- Status: active
- As of: 2026-11-12

No external tools are registered yet.

Add one `## <tool-id>` section per tool. Keep exact versions, provenance, checksums and smoke commands in the entry; do not commit tool binaries. The schema and lifecycle are in [[AGENT__procedure__tooling]].

A tool that will gate CI or send project data outside the machine also needs a `Decision: [[ADR__...]]` link to an Accepted ADR before it can be used.
