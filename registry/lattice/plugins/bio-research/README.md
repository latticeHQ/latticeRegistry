---
display_name: "Bio Research"
description: "Connect to preclinical research tools and databases (literature search, genomics analysis, target prioritization) to accelerate early-stage life sciences R&D"
icon: "../../.icons/1f468-200d-2695-fe0f.png"
verified: true
tags: ["biology", "research", "genomics", "clinical"]
---

# Bio Research

Connect to preclinical research tools and databases (literature search, genomics analysis, target prioritization) to accelerate early-stage life sciences R&D.

## Skills

| Name | Type | Description |
|------|------|-------------|
| `bio-research-start` | command | Start a bio research session |
| `bio-research-instrument-data-to-allotrope` | skill | Convert instrument data to Allotrope format |
| `bio-research-nextflow-development` | skill | Develop and manage Nextflow pipelines |
| `bio-research-scientific-problem-selection` | skill | Identify and prioritize scientific problems |
| `bio-research-scvi-tools` | skill | Use scVI tools for single-cell analysis |
| `bio-research-single-cell-rna-qc` | skill | Quality control for single-cell RNA data |

## MCP Servers

| Server | URL |
|--------|-----|
| pubmed | https://pubmed.mcp.claude.com/mcp |
| biorender | https://mcp.services.biorender.com/mcp |
| biorxiv | https://mcp.deepsense.ai/biorxiv/mcp |
| c-trials | https://mcp.deepsense.ai/clinical_trials/mcp |
| chembl | https://mcp.deepsense.ai/chembl/mcp |
| synapse | https://mcp.synapse.org/mcp |
| wiley | https://connector.scholargateway.ai/mcp |
| owkin | https://mcp.k.owkin.com/mcp |
| ot | https://mcp.platform.opentargets.org/mcp |

## Connectors

| Category | Placeholder | Included servers | Other options |
|----------|-------------|-----------------|---------------|
| Literature | `~~literature` | PubMed, bioRxiv | Google Scholar, Semantic Scholar |
| Scientific illustration | `~~scientific illustration` | BioRender | -- |
| Clinical trials | `~~clinical trials` | ClinicalTrials.gov | EU Clinical Trials Register |
| Chemical database | `~~chemical database` | ChEMBL | PubChem, DrugBank |
| Drug targets | `~~drug targets` | Open Targets | UniProt, STRING |
| Data repository | `~~data repository` | Synapse | Zenodo, Dryad, Figshare |
| Journal access | `~~journal access` | Wiley Scholar Gateway | Elsevier, Springer Nature |
| AI research | `~~AI research` | Owkin | -- |
| Lab platform | `~~lab platform` | Benchling\* | -- |

\* Placeholder -- MCP URL not yet configured
