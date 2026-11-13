# Sanitation Access in São Paulo’s Favelas

*Master’s dissertation in Public Policy, Insper · Luciana Maselli*

## Research question

Which factors are associated with access to water and sewer networks in São Paulo’s favelas? I wanted to understand how sanitation coverage varies across settlements and what that variation could tell municipal decision-makers about coordinating infrastructure, housing, and other public services.

## Data and methods

In 2020, I used QGIS to georeference and integrate data from multiple sources into a favela-level dataset. I combined data from the Centro de Estudos da Metrópole (CEM, 2016), based on Brazil’s 2010 Population Census, with georeferenced records from GeoSampa, HabitaSampa, the 2011 School Census, and Brazil’s Open Data Portal, including records of interventions under the first Growth Acceleration Program (PAC I). I also used district and subprefecture statistics published by São Paulo’s municipal urban planning department.

I used regression analysis in Stata to examine associations between the share of households with access to water and sewer networks and characteristics identified in the literature, including public services, housing tenure and land regularization, and the location of each favela.

## What the analysis found

- Sanitation coverage was associated with the presence of PAC interventions and schools in the favelas studied.
- Property registration, a component of land tenure regularization, was associated with sanitation coverage.
- The analysis found no correlation between a favela’s central location and sewer access. Favelas in peripheral areas located in better-off districts tended to have higher sanitation coverage.

## Implications for public policy

The findings are correlational. They suggest that São Paulo should consider sanitation alongside housing, land tenure regularization, and other public services when designing favela upgrading programs. The association with school presence also raises a question for future research about how education infrastructure and other public investments are coordinated in underserved neighborhoods.

## Analysis code

The [Stata do-file](sanitation_analysis.do) documents selected analyses from the dissertation workflow, including linear regressions for water and sewer coverage and probit models with average marginal effects for groups defined by sewer coverage. It takes a local dataset path as input and writes a local analysis log using built-in Stata commands. This revision was reviewed without execution and has yet to be checked against the final dissertation tables.

## Data availability

The integrated dataset is private while I prepare the research for publication.
