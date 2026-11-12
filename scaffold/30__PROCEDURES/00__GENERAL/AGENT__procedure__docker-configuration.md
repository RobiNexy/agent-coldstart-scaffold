# AGENT__procedure__docker-configuration

## Capability Activation: Docker Configuration

The config file is not the deliverable. What's being delivered is a reproducible path from a clean checkout to a healthy, verified stack on the target host; the Dockerfile and compose file are the residue of that path.

Treat the work as a boundary problem across three planes: build time (dependencies, source, user, entrypoint — baked into layers), runtime (writable layer, processes, sockets, scratch files — ephemeral by default), and environment (what legitimately differs per host — endpoints, credentials, resource caps, exposed surface). Every line in either file is an answer to "which plane does this belong to". The two recurring errors are state frozen into a layer that should have been mounted, and environment values pinned into a file that should have been injected. Settle the boundary before writing anything; most bad Docker configuration is a boundary error wearing correct syntax.

Priority:

- First — whether it comes up, and whether data survives. Port conflicts and network reachability; startup ordering versus actual readiness; mount paths, uid/gid ownership, permission bits on the mounted tree. Whether stateful bytes land in a named volume, a bind mount, or the writable layer. Whether a credential can be recovered afterward from an image layer, the build cache, image history, or `docker inspect`.
- Next — whether it stays up and stays diagnosable. PID 1 and signal handling, a healthcheck that separates hung from working, restart policy, resource and log caps, layer ordering and cache hits, base image provenance and size, non-root execution.
- Actively avoid — orchestration features sized for a scale nobody stated; hardcoded hostnames and absolute paths; floating `latest`; wrapper Makefiles or a second "production" file set produced unasked.

Failure modes, ordered by how often each is the actual cause. Walk down until the stack in hand stops matching, then stop — reporting the tail for its own sake is noise.
1. Mutable data in the writable layer: gone on `compose down`, unnoticed until the container is recreated.
2. Bind mount ownership: host uid not matching container uid, or a host directory the image never created. Surfaces as permission denied at runtime, never at build.
3. `depends_on` read as readiness: the dependent process starts, fails to connect, exits, and the restart policy rebrands it as a crash loop.
4. Secrets passed through `ENV` or build `ARG`: recoverable from image history and `inspect`.
5. `COPY . .` placed before dependency install: every source edit busts the dependency layer.
6. No `.dockerignore`: `node_modules`, `.git`, local venvs into the build context — slow, and able to shadow the in-image install.
7. No init as PID 1: `SIGTERM` never reaches the process, every shutdown runs to the timeout and ends in `SIGKILL`.
8. Port published on all interfaces: a development database reachable from the host's network.
9. Floating tag: rebuilding another day yields a different stack from an unchanged file.
10. Unbounded log driver: the disk fills, and the cause is not where anyone looks first.
11. No healthcheck: the restart policy cannot distinguish hung from healthy.
12. Architecture mismatch: an image built for the other platform, running under emulation or failing at exec.

Recurring decision points, stated as conditions rather than rules:
- Volume, bind, or tmpfs — bind when a person or another host-side tool must touch the files; named volume when the data belongs to the container and should not be hand-edited; tmpfs for anything that may legitimately vanish (caches, sockets, scratch).
- `ENV`, build `ARG`, or secret mount — `ENV` for values that are genuinely part of the image's runtime identity, `ARG` only for build switches that leave no trace in a layer, secret mounts for anything that must not be recoverable.
- Multi-stage — worth it when a compiler or package-manager cache would otherwise ship; not worth it for a stack that is already one installed artifact. Say so instead of adding stages for symmetry.
- Base image — take the smallest one that keeps glibc, DNS resolution, and timezone data working for this runtime; if musl is a risk, the image size is not worth it.
- Ordering — prefer a healthcheck plus a client that retries over start-order choreography. Compose supports `condition: service_healthy`; that idiom does not transfer to an orchestrator expecting readiness probes, so name the boundary rather than assuming portability.
- Read-only root, non-root user, dropped capabilities — apply where the image permits, and list the paths that must stay writable as the price.

How to proceed:
1. Establish the contract before any file. Target runtime (single host or orchestrated), how the image is built or pulled, where each piece of state lives, how secrets enter, which ports are truly public. Anything unstated becomes a placeholder variable in `.env`, mirrored into `.env.example`; never invent hosts, passwords, or absolute paths.
2. Emit the file set: Dockerfile, compose file, `.env.example`, `.dockerignore`. Nothing further unless asked.
3. Carry the trade-off rationale as one inline comment at the decision site and nowhere else — no explanation section, no README restating the files.
4. Close with a minimal runnable path and a single verification step: the command, and what a working result looks like. Configuration with no stated way to tell it worked is unfinished.
5. Hardening arrives as "add this line here", not as a second configuration. Keep the minimal path minimal.

Where the ground is unclear: unknown deploy target or data ownership → ship the minimal single-host compose, mark `[unconfirmed]`, and state the assumption behind it. Bind mount and named volume both defensible → `[another reading]` plus the condition that separates them. Multi-stage, read-only root, orchestration → `[depends]`, decided by the stated scale, never applied by default. Do not resolve an ambiguity by silently choosing the more elaborate option.

The output is the final deliverable. No process narration, no preamble, no sign-off; nothing inside the output — including comments, parentheticals, and footnotes — describes revisions, diffs, or the state of this pass. Such notes belong outside the output only.
