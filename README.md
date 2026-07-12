# Intrinsic capacity, environmental support, and observed disability transitions

This repository contains the minimum code and aggregate results needed to inspect the
primary model specification and redraw the three main figures accompanying the manuscript
*Intrinsic capacity modifies the association between environmental support and transition
to observed disability: a harmonised study of five ageing cohorts*.

**No individual participant data are included.**

## Repository contents

- `R/model_specification.R`: three-state transition structure, covariate formula, cohort
  model interface, and random-effects pooling with Hartung-Knapp inference.
- `R/reproduce_main_figures.R`: redraws Figures 1-3 from the aggregate CSV.
- `data/aggregate_figure_data.csv`: cohort-level or pooled estimates already displayed in
  the manuscript; it contains no participant identifiers or record-level observations.
- `DESCRIPTION`: R and package requirements.
- `LICENSE`: MIT License for code.
- `DATA_LICENSE.md`: CC BY 4.0 notice for the aggregate CSV.

## Data availability

The individual participant data are not redistributed in this repository. They remain
available from the originating studies under their respective registration, application,
and data-use conditions: [HRS](https://hrs.isr.umich.edu),
[ELSA](https://www.elsa-project.ac.uk), [CHARLS](https://charls.pku.edu.cn),
[SHARE](https://share-eric.eu), [MHAS](https://www.mhasweb.org), and
[KLoSA](https://survey.keis.or.kr). Harmonised resources may also require registration
through the [Gateway to Global Aging Data](https://g2aging.org).

The authors are not permitted to redistribute the source interview records or derived
participant-level analytic files. The aggregate CSV in this repository is an author-created
reporting dataset containing only results needed to redraw the main figures.

## Use

Use R 4.4 or later and install the packages listed in `DESCRIPTION`. From the repository
root, run:

```bash
Rscript R/reproduce_main_figures.R
```

The script creates `Figure1.pdf`, `Figure2.pdf`, and `Figure3.pdf` in a local `figures`
directory. Set the environment variable `FIGURE_OUTPUT_DIR` to use another output folder.

`R/model_specification.R` expects a user-supplied panel with generic columns documented in
that file. It does not download, reconstruct, or harmonise the restricted cohort data.

## Interpretation caveats

The primary result is an observational relative-scale interaction for transition from
independence to observed disability. Additive interaction and episode-stage differences
were not established. Recovery and mortality estimates were definition sensitive, and the
prediction interval indicates limits to cross-system transportability. The code and
aggregate results do not establish causality, intervention benefit, or deployable clinical
prediction performance.

## Licenses

Code is released under the MIT License. `data/aggregate_figure_data.csv` is released under
the Creative Commons Attribution 4.0 International License. Neither license applies to the
source cohort data.

## Citation

Repository: https://github.com/outrotim/ic-environment-disability-transitions

Companion manuscript citation and archival DOI will be added after acceptance or deposit.
