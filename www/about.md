User Guide
================

* [Overview](#overview)
* [Data settings](#data-settings)
  * [Data Type](#type)
  * [Dataset](#dataset)
  * [Import Data](#import)
* [General settings](#gen-settings)
  * [Endpoint](#endpoint)
  * [Knots](#knots)
  * [Bootstraps](#bootstraps)
* [Output](#output)
  * [Data Summary](#summary)
  * [Rarefaction and Predction](#inext)
  * [Plot Figures](#plot)  
* [Reference](#reference)

* * * * * * * *

<h2 id="overview">Overview</h2>

The program **iNEXT** (**iN**terpolation and **EXT**rapolation) online is written by [R][] language and built interactive web application using [Shiny][]. iNEXT supports abundance data and incidence data to compute the following species diversity curves and associated 95% confidence intervals:

1. Sample-size-based species diversity curve: species richness estimates for rarefied and extrapolated samples. Refer to Colwell et al. (2012) for details.

2. Sample completeness curve: sample completeness (as measured by sample coverage) with respect to sample size. This curve provides a bridge between sample-size- and coverage-based rarefaction and extrapolation. Refer to Chao et al. (2013, under revision) for details.

3. Coverage-based speceis diversity curve: species richness estimates for rarefied and extrapolated samples for coverage. Refer to Chao and Jost (2012) and Chao et al. (2013, under revision) for details.

iNEXT provides demonstration datasets for abundance data and incidence data:
* Abundance data: tropical foliage insects datasets: Oldgrowth and Secondgrowth (Janzen 1973a, b)
* Incidence data: tropical rain forest ants dataset: Berlese, Malaise and fogging (Longino et al. 2002)

[R]: http://www.r-project.org/
[Shiny]: http://www.rstudio.com/shiny/


<h2 id="data-settings">Data Settings</h2>
<h3 id="type">Data Type</h3>
iNEXT supports two types data to compute species diversity curves:

* Abundance data: a vector of the number of individuals (abundance) counted and identified to species in the sample.

* Incidence data: a vector of the number of sampling units counted and identified to species in the sample.

User should select one of data types to compute speceis diversity curves. Note that not only the data formats but also the analyses methods of these two data types are different, make sure you select right data type to analysis.

<h3 id="dataset">Dataset</h3>
All the demo data name or imported data name (see [Import Data](#import) for details) are listed in this list box that can be used to choose a single or multiple data to compute speceis diversity curves.

<h3 id="import">Import Data</h3>
iNEXT provides a visualized import data function. After checking the checkbox: **Import data**, user can input data (line by line) in the textarea and these imported data name would be listed in the list box: **Select dataset**. Note that the import formates are different between abundance data and incidence data. We introduce the import formates for two data types severally.
* Import abundance data: 
  take spider data with two canopy manipulation treatments (Girdled and Logged collected by Ellison et al. 2010 and Sackett et al. 2011) as example:
  
  ```{r}
  Girdled 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1 
  Logged 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1
  ```

The import data contain two lines (separated by return, "↵"), first line is Girdled treatment and second is Logged treatment. **For each line, the first element is the data name (cannot start with a digit) and the others are abundance frequency counts.** For each line, all element should be separated by blank space (" ").

* Import incidence data:
  take ant data (the 1500m and 2000m elevations on the Barva Transect in northeastern Costa Rica collected by (Longino and Colwell 2011) as example:
  
  ```{r}
  Ant_1500m 200 144 113 79 76 74 73 53 50 43 33 32 30 29 25 25 25 24 23 23 19 18 17 17 11 11 9 9 9 9 6 6 5 5 5 5 4 4 3 3 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1
  Ant_2000m 200 80 59 34 23 19 15 13 8 8 4 3 2 2 1
  ```

The import data contain two lines (separated by return, "↵"), first line is Ant.1500m treatment and second is Ant.2000m. **For each line, the first element is the data name (cannot start with a digit), the seceond elemet is number of sampling units and the others are incidence frequency counts.** For each line, all element should be separated by blank space (" ").

<h2 id="gen-settings">General settings</h2>
<h3 id="endpoint">Endpoint</h3>
Endpoint is a value specifying the sample size or sample coverage for extrapolation; default is double the reference sample size (for abundance data) or number of reference sampling units (for incidence data). iNext sets the minima endpoint as reference sample size and maxima as the extrapolated sample size tend to 99.9% sample coverage.

<h3 id="knots">Knots</h3>
Number of knots (say K, default is 40) is the smoothing control factor of speceis diversity curves. **Choose larger K for smoother curves. However, it takes more time to compute output.** For detials, iNEXT sets half knots for rarefaction (interpolation) part, and another half knots for prediction (extrapolation) part. 
* For abundance data:

  Suppose K is 20, reference sample size n is 72 and [endpoint](#endpoint) is 200. The sample size sequences (say m) are following:
  ```{r}
  1   8  16  24  32  40  48  56  64  72  84  97 110 123 136 148 161 174 187 200   
  ```
  First 10 elements belong to interpolation part, and the 10th element is reference sample size;
  Last 10 elements belong to extrapolation part, and the 20th element is endpoint.
  In both parts, the sample size sequences were generated approximately equally spaced.

* For incidence data:

  Suppose K is 20, the number of reference sampling units T is 20 and [endpoint](#endpoint) is 62. The sequence of number of sampling units (say t) are following:
  ```{r}
  1  3  5  7  9 11 13 15 17 20 24 28 32 36 41 45 49 53 57 62
  ```
  First 10 elements belong to interpolation part, and the 10th element is number of reference sampling units;
  Last 10 elements belong to extrapolation part, and the 20th element is endpoint.
  In both parts, the sample size sequences were generated approximately equally spaced.

<h3 id="bootstraps">Bootstraps</h3>
Number of bootstraps (say B) is an integer specifying the number of replications for bootstrap resampling scheme in computing variance and constructing 95% confidence intervals. Refer to Chao et al. (2013, under revision) for details.

<h2 id="output">Output</h2>
<h3 id="summary">Data Summary</h3>
This tab panel shows a basic data information for the selected data. The explanation of output symbols are shown in the bottom of the tab panel. Click [Download as csv file]() to download the output summary.

<h3 id="inext">Rarefaction and Predction</h3>
This tab panel shows the main output for iNEXT. The explanation of output symbols are shown in the bottom of the tab panel. Click [Download as csv file]() to download the output table.

<h3 id="plot">Plot Figures</h3>
This tab panel shows three species diversity curves (introduced in [Overview](#overview)). Click [Download as PDF]() to download the figure.

  
<h2 id="reference">Reference</h2>

1. Chao, A., and L. Jost. 2012. Coverage-based rarefaction and extrapolation: standardizing samples by completeness rather than size. Ecology 93:2533-2547.

2. Chao, A., N. J. Gotelli, T. C. Hsieh, E. L. Sander, K. H. Ma, R. K. Colwell, and A. M. Ellison 2013. Rarefaction and extrapolation with Hill numbers: a unified framework for sampling and estimation in biodiversity studies, Ecological Monographs (under revision).

3. Colwell, R. K., A. Chao, N. J. Gotelli, S. Y. Lin, C. X. Mao, R. L. Chazdon, and J. T. Longino. 2012. Models and estimators linking individual-based and sample-based rarefaction, extrapolation and comparison of assemblages. Journal of Plant Ecology 5:3-21.

4. Ellison, A. M., A. A. Barker-Plotkin, D. R. Foster, and D. A. Orwig. 2010. Experimentally testing the role of foundation species in forests: the Harvard Forest Hemlock Removal Experiment. Methods in Ecology and Evolution 1:168-179.

5. Hsieh, T. C., K. H. Ma, and A. Chao. 2013. iNEXT online: interpolation and extrapolation for specise diversity curve (Version 1.0) [Software]. Available from http://chao.stat.nthu.edu.tw/inext/.

6. Janzen, D. H. 1973a. Sweep samples of tropical foliage insects: effects of seasons, vegetation types, elevation, time of day, and insularity. Ecology 54:687-708.
  
7. Janzen, D. H. 1973b. Sweep samples of tropical foliage insects: description of study sites, with data on species abundances and size distributions. Ecology 54:659-686.

8. Longino, J. T., J. Coddington, and R. K. Colwell. 2002. The ant fauna of a tropical rain forest: estimating species richness three different ways. Ecology 83:689-702.

9. Longino, J. T., and R. K. Colwell. 2011. Density compensation, species composition, and richness of ants on a neotropical elevational gradient. Ecosphere 2:art29.

10. Sackett, T. E., S. Record, S. Bewick, B. Baiser, N. J. Sanders, and A. M. Ellison. 2011. Response of macroarthropod assemblages to the loss of hemlock (Tsuga canadensis), a foundation species. Ecosphere 2: art74.
