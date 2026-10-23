# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`GraniteWMS/MarketPlaceDev` is the **dev/test content repository** of the Granite WMS artifact Marketplace. There is no code here: it stores published artifact units, which the Marketplace API (`C:\Work\SC\GraniteMarketplaceApi`, see its CLAUDE.md) writes through pull requests and Granite Custodian (`C:\Work\SC\GraniteCustodian`) builds, publishes and deploys. The API's local `.env` / `.env.test` point `MARKETPLACE_REPO_NAME` at this repo. The production counterpart is `GraniteWMS/Marketplace` (`C:\Work\SC\Marketplace`), which still holds the older one-file-per-artifact layout.

`WARP.md` (untracked locally) is stale guidance for another agent: it describes the old `_metadata.json` layout and a `publish-metadata.yml` workflow that no longer exists. `README.md` is a one-line placeholder.

## Storage layout (unit format)

```
{owner}/{TYPE}/{slug}/v{N}/artifact-manifest.json   # the manifest, fixed file name, Version = N
{owner}/{TYPE}/{slug}/v{N}/<path>                   # content files at their own relative paths
{owner}/{TYPE}/{slug}/latest/...                    # mirror of the newest version, manifest stamped "Version": 0
```

- `owner` is the publisher's GitHub login; `slug` is derived from the name (`-1`, `-2`... on collision). Example: `JoshMeijer/PROCESS/cage-receiving/v1/` holds `artifact-manifest.json`, `process.json`, `webtemplates/step-2.html` and `VIEW/dbo.WebTemplate_CageReceiving_Document/script.sql`.
- The manifest's `Components` lists `{ Type, Name, Path, DependsOn }` in deploy order; `Path: ""` is the unit's own object at the version root. Units are self-contained: there are no `ArtifactDependencies` / `PostDeployArtifacts` references to other artifacts.
- At the time of writing the repo holds only `PROCESS` units (owners `JoshMeijer`, `Gabriel-Innes`), all at `v1`.
- `.gitattributes` is `* -text`: files are stored byte for byte. Never normalise line endings or re-encode files, or downloads stop matching what was published.

## How content gets here

1. Custodian calls the Marketplace API, which commits `v{N}/` plus the `latest/` mirror to a `publish-...` branch **as the publishing user** (their OAuth token) and opens a PR titled `Publish: X`, `Update: X`, `Update metadata: X` or `Deprecate artifact: X`. The PR body carries ``**Publish Request**: `<uuid>` ``.
2. `.github/workflows/auto-approve-codeowner-pr.yml` (`pull_request_target`) approves the PR when its author is a CODEOWNER of at least one changed file.
3. On merge, `pr-lifecycle.yml` (push to `main`) reads `(#N)` from the head commit subject, pulls the publish request id from PR #N's body and `POST`s `{MARKETPLACE_API_URL}/api/v1/publish-requests/{id}/finalize` with `{"merged": true}`. Only then does the API move the staged row into `artifact_registry`. The regex needs a squash-style subject ending in `(#N)`; a "Merge pull request #N" commit is not matched and the request is never finalized.
4. `pr-closed.yml` (PR closed without merge) calls the same endpoint with `{"merged": false}`, which discards staging.

`.github/CODEOWNERS` has one `{owner}/* @{owner}` line per publisher; the API appends these itself when an account is linked. `publish-elasticsearch-reusable.yml` is `workflow_call` only, nothing in this repo calls it, and it reads `*_metadata.json` files that the unit format no longer has; the API now searches Postgres, so it appears unused.

**Workflow secrets** (GitHub repo settings, not verifiable from a clone): `MARKETPLACE_API_URL`, `MARKETPLACE_CALLBACK_API_KEY` (sent as `X-GitHub-Callback-Key`; must match the API's callback key), plus `ES_URL` / `EMBEDDINGS_URL` for the Elasticsearch workflow. If the callback secrets are wrong, PRs merge but publish requests stay `pending_pr`.

## Rules

- Do not hand-edit or delete anything under a publisher folder. Published `v{N}/` content is immutable (only the API's metadata/deprecation patch PRs rewrite a version's `artifact-manifest.json`), and `latest/` must always mirror the highest version. Changes go through Custodian/the API.
- Content committed directly (the `maint:` commits) bypasses publish requests, so `artifact_registry` does not know about it until the API's `backfill_artifact_registry.py` is run; the backfill skips owners who have no Marketplace account.
- The API ignores root-level files (it only reads `{owner}/{TYPE}/{slug}/v{N}/`) and builds commits on the existing tree, so `CLAUDE.md`, `README.md` and `.gitattributes` survive publishes.
- When wiping the repo (as in `maint: reset repo`), keep `.github/` (the finalize callbacks depend on it), `.gitattributes` and the root docs; delete only publisher folders, and drop the API's affected tables as its CLAUDE.md describes.
- The current content was imported from the Process Catalog by `C:\Work\SC\GraniteProcessCatalog\scripts\migrate_to_marketplace.py`, which defaults to this repo as a sibling folder.

## Useful read-only commands

```bash
git log --oneline -30                                         # publishes are "(#N)" squash merges; maint: commits are manual
git ls-files '*/artifact-manifest.json' | grep -v /latest/    # every published version
git ls-files | cut -d/ -f1-2 | sort | uniq -c                 # files per owner/type
```
