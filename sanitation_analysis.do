* Sanitation access in Sao Paulo's favelas
* Luciana Maselli | Master's dissertation in Public Policy, Insper
*
* Usage: do sanitation_analysis.do "path/to/private.dta" "path/to/new.log"
* Run in a fresh Stata session. Use a new log path for each run.
* The log defaults to sanitation_analysis.log and may contain research results.
*
* Input: a favela-level dataset assembled in QGIS from census, administrative,
* and geospatial sources. See README.md for data provenance.
* Scope: selected Stata analyses from the recovered dissertation do-file.
* Estimates describe associations. The script was reviewed without execution
* and has not been reconciled with the final dissertation tables.

args data_file log_file
if `"`data_file'"' == "" {
    display as error "Supply the path to the private Stata dataset."
    exit 198
}
confirm file "`data_file'"
if `"`log_file'"' == "" {
    local log_file "sanitation_analysis.log"
}
confirm new file "`log_file'"
set more off
use "`data_file'", clear

foreach variable in ///
    AREA PO_AGUA PO_ESGOTO _PO_AGUA _PO_ALUG ///
    _PO_CEDIDO _PO_ESGOTO _PO_INVASAO _PO_PROPRIO _anos_de_estudo_medio ///
    _cultura_bibliotecas_sum _cultura_espaçosculturais_su _declividade_05a25absol _declividade_05a25daá _declividade_0a05absolu ///
    _declividade_0a05daár _declividade_25a60absol _declividade_25a60daá _declividade_60absoluto _declividade_60daárea ///
    _densidadedemográfica _educação_publica_ceu_sum _educação_publico_fundamental _ensino_publico_infantil_sum _esporte_centro_esportivo_sum ///
    _esporte_clubes_da_comunidade _saude_ame_sum _saúde_UBS_sum _saúde_hospital_sum {
    confirm numeric variable `variable'
}

log using "`log_file'", name(sanitation) text
local services _ensino_publico_infantil_sum _educação_publico_fundamental ///
    _educação_publica_ceu_sum _saude_ame_sum _saúde_UBS_sum ///
    _saúde_hospital_sum _esporte_centro_esportivo_sum ///
    _esporte_clubes_da_comunidade _cultura_bibliotecas_sum ///
    _cultura_espaçosculturais_su
local tenure _PO_PROPRIO _PO_ALUG _PO_CEDIDO _PO_INVASAO
local controls AREA _densidadedemográfica

* Sewer access and public services
regress _PO_ESGOTO _anos_de_estudo_medio
correlate _PO_ESGOTO _anos_de_estudo_medio, cov
regress _PO_ESGOTO _ensino_publico_infantil_sum _educação_publico_fundamental _educação_publica_ceu_sum, vce(robust)
regress _PO_ESGOTO _saude_ame_sum _saúde_UBS_sum _saúde_hospital_sum, vce(robust)
regress _PO_ESGOTO _esporte_centro_esportivo_sum _esporte_clubes_da_comunidade, vce(robust)
regress _PO_ESGOTO _cultura_bibliotecas_sum _cultura_espaçosculturais_su, vce(robust)
regress _PO_ESGOTO `services', vce(robust)
correlate _PO_ESGOTO `services'
regress _PO_ESGOTO `services' `controls', vce(robust)

* Sewer access and housing tenure
regress _PO_ESGOTO `tenure', vce(robust)
regress _PO_ESGOTO `tenure' `controls', vce(robust)
correlate _PO_ESGOTO `tenure' `controls'

* Sewer access and terrain slope
* The final specification below retains the mixed units in the recovered code.
regress _PO_ESGOTO _declividade_0a05daár _declividade_05a25daá _declividade_25a60daá _declividade_60daárea, vce(robust)
correlate _PO_ESGOTO _declividade_0a05daár _declividade_05a25daá _declividade_25a60daá _declividade_60daárea
regress _PO_ESGOTO _declividade_0a05absolu _declividade_60daárea _declividade_05a25absol _declividade_25a60absol _declividade_60absoluto, vce(robust)

* Access ranks use 100 quantile groups. Ties may produce unequal group sizes.
* The two sewer indicators use the original cutoffs and are not complements.
capture drop ranking_esgoto
xtile ranking_esgoto = _PO_ESGOTO, n(100)
tabulate ranking_esgoto
histogram PO_ESGOTO
capture drop ranking_agua
xtile ranking_agua = _PO_AGUA, n(100)
tabulate ranking_agua
capture drop mais_vulneravel
generate byte mais_vulneravel = (ranking_esgoto <= 10) if !missing(ranking_esgoto)
capture drop menos_vulneravel
generate byte menos_vulneravel = (ranking_esgoto >= 70) if !missing(ranking_esgoto)
tabulate mais_vulneravel
tabulate menos_vulneravel

* Probit models for lower sewer-access ranks
probit mais_vulneravel `services'
margins, dydx(`services') post
probit mais_vulneravel `services' AREA
margins, dydx(`services' AREA) post
probit mais_vulneravel `services' _densidadedemográfica
margins, dydx(`services' _densidadedemográfica) post
probit mais_vulneravel `services' `controls'
margins, dydx(`services' `controls') post

* Probit models for higher sewer-access ranks
probit menos_vulneravel `services'
margins, dydx(`services') post
probit menos_vulneravel `services' AREA
margins, dydx(`services' AREA) post
probit menos_vulneravel `services' _densidadedemográfica
margins, dydx(`services' _densidadedemográfica) post
probit menos_vulneravel `services' `controls'
margins, dydx(`services' `controls') post

* Housing tenure and higher sewer-access ranks
probit menos_vulneravel `tenure'
margins, dydx(`tenure') post
probit menos_vulneravel `tenure' AREA
margins, dydx(`tenure' AREA) post
probit menos_vulneravel `tenure' _densidadedemográfica
margins, dydx(`tenure' _densidadedemográfica) post
probit menos_vulneravel `tenure' `controls'
margins, dydx(`tenure' `controls') post

* Water access and public services
correlate _PO_AGUA `services'
regress _PO_AGUA `services', vce(robust)
regress _PO_AGUA `services' `controls', vce(robust)

* Water access and housing tenure
correlate _PO_AGUA `tenure' `controls'
regress _PO_AGUA `tenure' `controls', vce(robust)
histogram PO_AGUA

log close sanitation
