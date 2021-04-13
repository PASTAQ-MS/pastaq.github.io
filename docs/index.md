---
title: PASTAQ
---

---

## PASTAQ: Pipelines And Systems for Threshold Avoiding Quantification

---

PASTAQ provides a set of tools for high-performance pre-processing of LC-MS/MS
data. Avoiding the use of arbitrary intensity thresholds in early stages of the
pipeline can aid in the detection of important biological low intensity signals
common in metabolomics and proteomics experiments.

The core of PASTAQ is implemented in C++ and currently comes in three flavours:

1. A C++ library to implement new high-performance tools.
2. Python bindings for general data processing, a default Data
   Dependent Acquisition (DDA) pipeline, and access to the tools to build custom
   analysis pipelines.
3. A graphical user interface (PASTAQ-GUI) for easy parametrization of the DDA
   pipeline (beta).

PASTAQ is suitable to build personalized pipelines using its algorithms for
isotope quantification, retention time alignment, deisotoping/feature detection,
and linkage of identifications obtained with any engine that outputs or can be
transformed to the mzIdentML format.

The default DDA pipeline can be used for proteomics and metabolomics analyses,
and outputs a variety of quantitative tables as described below , as well as
quality control plots that can be used to assess the accuracy of the data and
pre-processing algorithms.

Currently annotation of peaks and features is implemented for proteomics using
mzIdentML standard, while similar annotation for metabolomics using
peaks/features accurate mass and MS/MS spectra can be implemented in
straightforward way.

### Installation

PASTAQ can be downloaded and compiled [from source][src] by downloading or
cloning the repository and following the instructions in the `README.md`.
Building from source requires CMake and a suitable C++ compiler. The standard
installation will build the PASTAQ C++ library and its corresponding Python
bindings.

We also provide standalone [PASTAQ-GUI][src-gui] installers for Windows in the
[release page][src-gui-releases].

[src]: https://github.com/PASTAQ-MS/PASTAQ
[src-gui]: https://github.com/PASTAQ-MS/PASTAQ-GUI
[src-gui-releases]: https://github.com/PASTAQ-MS/PASTAQ-GUI/releases

### Basic Usage

The following instructions apply to the usage of PASTAQ's built-in Python
bindings.

### Further Developments

We continue to develop PASTAQ, and are always open for collaborations to add new
algorithms and improve the quality of the existing tools. If you want to get
involved, feel free to [get in touch][contact] with us to discuss prospective
projects.

[contact]: mailto:a.sanchez.brotons@rug.nl

### DDA Pipeline Parameters

The following is an explanation of the parameters that can be configured for the
DDA pipeline. In general, the default parameters can be used directly with the
exception of the instrument related configuration. The following prepares the
parameters for data acquired with an Orbitrap instrument with 70000 resolution
at reference m/z of 200 and expected peak width in retention time of 20 seconds
(FWHM).

```
import pastaq

params = pastaq.default_parameters('orbitrap', 20)
params['resolution_ms1'] = 70000
params['reference_mz'] = 200
```

#### Input files

The input files can be passed to the pipeline in the following way:

```
input_files = [
    {'reference': False, 'raw_path': '1_1.mzXML', 'group': 'a', 'ident_path': '1_1.mzid'},
    {'reference': False, 'raw_path': '1_2.mzXML', 'group': 'a', 'ident_path': '1_2.mzid'},
    {'reference': False, 'raw_path': '1_3.mzXML', 'group': 'a', 'ident_path': '1_3.mzid'},
    {'reference': False, 'raw_path': '2_1.mzXML', 'group': 'b', 'ident_path': '2_1.mzid'},
    {'reference': False, 'raw_path': '2_2.mzXML', 'group': 'a', 'ident_path': '2_2.mzid'},
    {'reference': False, 'raw_path': '2_3.mzXML', 'group': 'a', 'ident_path': '2_3.mzid'},
]
```

If `reference` is enabled for a single file, it will be used for retention time
alignment. If it is set for multiple files, a similarity search will be
performed to find the most optimal reference for alignment. If the `reference`
field is not present in any files or set to false in all of them, an exhaustive
similarity search will be performed to identify the optimal reference for
retention alignment of the whole dataset.

`raw_path` specifies the path to the `.mzXML` or `.mzML` file, and `ident_path`
the corresponding identification file in `.mzIdentML` version 1.1+ format.

The `group` is used for the selection of isotope peaks or features that are
present in at least a given percentage of samples in any given group as
described below.

#### Instrument configuration

These parameters are used mostly for configuring the extent of smoothing that is
applied when resampling the data and the initial estimation of the
region-of-interest (ROI) for the quantification of isotope peaks via peak
fitting.

##### `instrument_type`

This parameter defines the type of mass spectrometer used for data acquisition.
Currently, PASTAQ supports Orbitrap (`orbitrap`), time-of-flight (`tof`),
(triple) quad (`quad`) and Fourier-transform ion cyclotron resonance (`fticr`).

##### `resolution_ms1`, `resolution_msn`, `reference_mz`

The selected resolution at the MS1 (`resolution_ms1`) and MS2 (`resolution_msn`)
levels with respect to the reference m/z (`reference_mz`).

##### `avg_fwhm_rt`

Estimated peak width in seconds of chromatographic peaks given as full-width
half-maximum. A preliminary exploration of some selected isotope peaks from the
extracted-ion chromatogram (XIC) or base-peak chromatogram (BIC) can be used to
measure a rough estimate of this parameter. Peak widths can vary widely
throughout the chromatographic range, so it is not necessary to provide an
accurate measurement. The current implementation expects no change in peak width
during the chromatographic elution, however, the Gaussian peak fitting algorithm
is tolerant to variations peak width in chromatographic peaks.

#### Raw data

When reading the raw data, the user can select an m/z or retention time range by
adjusting `min_mz`, `max_mz`, `min_rt` and `max_rt` parameters. Additionally, if
the data contains scans in both positive and negative polarities, the `polarity`
setting must be adjusted to `'pos'` or `'neg'` respectively. Failure to do so
will impact further pre-processing steps such as resampling and peak detection.
Positive and negative polarities should thus be separated in different output
directories.

#### Resampling

These parameters can be used for controlling the extent of smoothing applied to
the data when resampling and to adjust the size of the output matrix. The
resampling procedure will project the raw data into a regular 2D map in which
the expected widths of peaks in both the retention time and m/z dimensions
remain the same throughout their respective ranges. This ensures that the number
of sampling points for all isotope peaks will be similar in the entire map.

By default, `num_samples_mz` and `num_samples_rt` establish that there will be
at least 5 sampling points within the FWHM of a peak in each dimension. This
should be sufficient for the estimation of initial local-maxima, but if not
enough memory is available in the system, it may be reduced at the user's
discretion.

The amount of smoothing can be controlled with `smoothing_coefficient_mz` and
`smoothing_coefficient_rt`, which act as a smoothing multiplier over the
Gaussian kernel set at the estimated width (in sigma units) that is
automatically calculated from the given instrumental settings and adjusted for
local peak resolution in m/z dimension.

#### Peak detection

Detection of isotopic peaks is performed automatically based on previous
settings, but the user may want to configure a maximum number of peaks to keep
with the `max_peaks` parameter. It is advised to keep this parameter at high
value, as noise discrimination is performed in the later peak matching stages of
the pipeline without

#### Retention time alignment

The retention time alignment algorithm (Warp2D) divides the retention time range
of chromatograms in `warp2d_num_points` equidistant sampling points. Windows of
`warp2d_window_size` number of points are used to establish the nodes at which
the warping will occur. The `warp2d_slack` indicates how many points the warping
nodes can be moved to shorten or extend a segment. When comparing the similarity
of each of the segment during the warping, a maximum number of the most abundant
isotope peaks (`warp2d_peaks_per_window`) can be adjusted, allowing to control
the calculation time. Note that the retention time range is expanded by
`warp2d_rt_expand_factor` at the beginning and end of the retention time range
to avoid edge effects.

As a practical example, if the retention time range goes from 0 to 1000 seconds,
with `warp2d_num_points = 1000`, `warp2d_window_size = 100` and `warp2d_slack
= 20`, the range will be divided in 1 second segments, with each alignment
window being 100 seconds long, and we can have a maximum warping deviation of
+/- 20 seconds.

The default parameters will work fine for common retention time run lengths, but
we are working to simplify the parametrization of Warp2D to use a selected
deviation in number of sigmas, similar to other parameters in the pipeline.

#### Deisotoping/Feature detection

The deisotoping/feature detection procedure does not require much
parametrization, as the parameters are derived automatically in previous steps.
The only setting the user may want to adjust is the
`feature_detection_charge_states` by selecting which charge states may be
explored.

#### Peak/Feature matching

When matching peaks/features across multiple files, a tolerance in m/z and
retention time in number of sigmas can be adjusted with `metamatch_n_sig_mz` and
`metamatch_n_sig_rt` respectively. Additionally, there is a filtering procedure
that ensures that only clusters of matched peaks that contain non-zero values in
a given percentage of samples are kept. This process works on individual groups,
so if `metamatch_fraction = 0.7`, with 10 samples from group `a` and 20 of group
`b`, a cluster will be retained if there are at least 7 samples from group `a`
or 14 samples from group `b` with non-zero values.

#### Annotation linking and identifications

As with other PASTAQ algorithms, the tolerance for linking MS/MS annotations and
identifications is expressed in number of sigmas in m/z and retention time using
the parameters `link_n_sig_mz` and `link_n_sig_rt`, respectively. In general,
for linked peptide-spectrum-matches (PSMs), we may want to keep all the
identifications, the user may want to keep all the identifications, not only the
ones that has the highest scores, the parameter `ident_max_rank_only` should be
set to `False`. Similarly, to keep annotations that don't meet the FDR threshold
or are marked as decoy, the parameters `ident_require_threshold` and
`ident_ignore_decoy` should be set to `False`, respectively.

#### Quality control plots

A number of parameters are available to configure the appearance of quality
control plots. A color palette can be set with `qc_plot_palette` parameter,
which will accept any color palette included in the `seaborn` library (`husl`,
`crest`, `Spectral`, `Flare`, etc.). By default image format is set to `png`.
Other formats can be set using `qc_plot_extension` parameter using common image
formats, such as `pdf`, `eps`, `tiff` or `svg`. The following configuration
parameters, can be used to adjust the general style of the output images:
`qc_plot_dpi` (Image DPI), `qc_plot_font_family` (Font family, e.g. `'serif'`,
`'sans-serif'`), `qc_plot_font_size`, `qc_plot_fig_size_x`,
`qc_plot_fig_size_y`. Plot legends are not enabled by default, to show the
legend, set `qc_plot_fig_legend` to `True`. However, this may make certain plots
with large number of chromatograms difficult to read.

When plots contain multiple samples, transparency (alpha) is used to blend the
different colors. The alpha can be controlled for each type of plot by changing
`qc_plot_fill_alpha`, `qc_plot_line_alpha`, `qc_plot_scatter_alpha` to a number
between 0.0 and 1.0. Alpha can be dynamically selected by setting these
parameters to `'dynamic'` instead. In that case the alpha would be calculated as
`alpha = 1 / n_samples`, and will never go below the value in
`qc_plot_min_dynamic_alpha`.

If `qc_plot_per_file` is used, individual images will be generated for each QC
plot, instead of having all plots stacked in one figure. Other adjustable QC
plot parameters include `qc_plot_line_style`, which will show certain plots
(e.g. XIC, density) as filled plots or line plots by selecting `'fill'` or
`'line'`, respectively. In some cases, the amount of points in the `mz vs
sigma_mz` scatterplot may be too large for visual assessment, therefore,
`qc_plot_mz_vs_sigma_mz_max_peaks` will select a maximum number of points to
use, and `qc_plot_scatter_size` parameter can be used to set the point size.

Similarity plots use the number of most intensive peaks set in
`similarity_num_peaks`.

#### Quantitative table generation

A number of quantitative metrics are calculated in different stages of the
pipeline. All this information is stored for the generation of the output `csv`
tables. To avoid generating unnecessary files, a quantitative metric must be
selected for isotopes (`quant_isotopes`) and features (`quant_features`).
Isotope quantification can be set to peak height (`'height'`) or peak volume
(`'volume'`). Likewise, features quantitative information can be based either on
the monoisotopic peak (`'monoisotopic_height'`, `'monoisotopic_volume'`), the
peak with the highest intensity (`'max_height'`, `'max_volume'`) or the sum of
all peaks in the isotopic distribution (`'total_height'`, `'total_volume'`).

When identification information is provided and
`quant_features_charge_state_filter` is set to `True`, annotations for features
in which the MS1 charge state differs from the one in the identification file
will be discarded in the feature quantitative tables.

The type of annotation linkage in `quant_ident_linkage` can be set to
`theoretical_mz` or `msms_event`, which set the annotations type in the
annotation tables either based on theoretical value of the highest scoring PSM
or based on precursor ion m/z stored in the raw data.

When identifications are present in more than one sample, a consensus
identification is generated for each peak or feature cluster as long as
`quant_consensus` is enabled. This consensus will select the identifications
that appear in the maximum number of files. Additionally will ignore
identifications that are not present in at least `quant_consensus_min_ident`
number of samples. By default, this is 2, but more stringent criteria could be
used to reduce false positives.

By default all annotations are saved with their corresponding associative tables
in addition to the aggregated versions. This can lead to very large files, and
thus `quant_save_all_annotations` can be disabled to save some time and disk
space.

Peptide tables are generated by aggregating clusters with the same consensus
sequence by summing up multiple charge states of the same peptide. For protein
group quantification it is necessary to use protein inference to select which
peptides to aggregate for which protein. A minimum number of peptides present
for a protein can be selected with `quant_proteins_min_peptides`. If
`quant_proteins_remove_subset_proteins` is enabled, peptides are only considered
for quantification of proteins (razor protein) with the highest number of mapped
peptides following parsimonious law. In case a peptide can't be assigned to
a unique protein as 'razor' the user can choose to use them for quantification
of all mapping proteins where the peptide could be considered as razor
(`quant_proteins_ignore_ambiguous_peptides` is set to `False`) or to ignore them
(`quant_proteins_ignore_ambiguous_peptides` is set to `True`). For protein
inference, the following quantifications can be selected with the
`quant_proteins_quant_type` parameter:


- 'unique': Only unique peptides are considered for quantification.
- 'razor': Unique and peptides assigned as most likely according to the Occam's
  razor constrain.
- 'all': All peptides will be used for quantification for all protein groups.
  Thus shared peptides will be used more than once.

<br/>

---
