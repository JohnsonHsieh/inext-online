User Guide
================

* [Overview](#overview)
  * [How to Cite](#cite)
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
  * [Rarefaction/Extrapolation](#inext)
  * [Figure Plots](#plot)  
* [References](#reference)

* * * * * * * *

<h2 id="overview">Overview</h2>

The program **iNEXT** (**iN**terpolation and **EXT**rapolation) online is written in the [R][] language and the interactive web application is built by using [Shiny][]. The user provides a vector of abundances of individual species (abundance data) or incidences of individual species (incidence data). iNEXT computes the following species richness estimates and associated 95% confidence intervals:

1. Sample-size-based rarefaction and extrapolation: species richness estimates for rarefied and extrapolated samples up to a size specified by the user (i.e., an endpoint, see below). Refer to Colwell et al. (2012) for details.

2. Coverage-based rarefaction and extrapolation: species richness estimates for rarefied and extrapolated samples for sample coverage up to a coverage specified by the user (i.e., an endpoint, see below). Refer to Chao and Jost (2012) for details.

iNEXT also plots the following three integrated sampling curves suggested in Chao et al. (2013) for unified sampling and estimation in species diversity analysis.

1. Sample-size-based rarefaction and extrapolation sampling curve: this curve plots the species richness estimates for a rarefied and extrapolated sample with respect to sample size up to a specified endpoint.

2. Sample completeness curve: this curve plots the sample completeness (as measured by sample coverage) with respect to sample size. The curve provides a bridge between sample-size- and coverage-based rarefaction and extrapolation.

3. Coverage-based rarefaction and extrapolation sampling curve: this curve plots the species richness estimates for rarefied sample and extrapolated sample with respect to sample coverage up to a specified endpoint.

<h3 id="cite">How to Cite</h3>
<font color="ff0000">If you use iNEXT to obtain results for publication, you should cite at least one of the relevant papers (Chao and Jost 2012; Colwell et al. 2012; Chao et al. 2013) along with the following reference for iNEXT:</font>
  
<p style="padding-left: 30px;">Hsieh, T. C., K. H. Ma, and A. Chao. 2013. iNEXT online: interpolation and extrapolation (Version 1.0) [Software]. Available from <a href="http://chao.stat.nthu.edu.tw/inext/">http://chao.stat.nthu.edu.tw/inext/</a>.</p>

To help refine iNEXT, your comments or feedbacks would be welcome (please send them to chao@stat.nthu.edu.tw).
 [R]: http://www.r-project.org/
[Shiny]: http://www.rstudio.com/shiny/


<h2 id="data-settings">Data Settings</h2>
<h3 id="type">Data Type</h3>
iNEXT supports two types of data for rarefaction and extrapolation:
* Abundance data: a vector of abundances of individual species in the sample.
* Incidence data: a vector of incidences of individual species in the sample (i.e., the number of sampling units that a species is found). 
User should select one of the data types to obtain output. Not only the data format but also the statistical method for the two data types are different. Please make sure you select the correct data type.

<h3 id="dataset">Dataset</h3>
Some demonstration datasets are used for illustration. 
* Abundance data: tropical foliage insects data in two sites: Oldgrowth and Secondgrowth (Janzen 1973a, b)
* Incidence data: tropical rain forest ants data by three collecting methods: Berlese, Malaise and fogging (Longino et al. 2002)
We suggest that you first run these demo datasets and try to understand the output before you import your own data sets. 
All the titles of the demo data and imported data (see [Import Data](#import) for details) are listed in this list box. You can choose a single dataset or multiple datasets for comparisons. 

<h3 id="import">Import Data</h3>
iNEXT provides a visualized import data function. After checking the checkbox: **Import data**, user can input data (line by line) in the text area; the title of your imported data will be listed in the box: **Select dataset**. The import formats for the abundance data and incidence data are different. The data formats for the two types of data are described below.
* Import abundance data: 
We use a simple example to show how to import abundance data. Consider the spider data with two canopy manipulation treatments (Girdled Treatment and Logged Treatment; data are provided in Ellison et al. 2010 and Sackett et al. 2011).
  
  ```{r}
  Girdled 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1 
  Logged 88 22 16 15 13 10  8  8  7  7  7  5  4  4  4  3  3  3  3  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  1  1
  ```

Since there are two datasets, the imported data contain two lines (separated by return, "↵"). The first line includes the species abundances for 26 species in the Girdled Treatment and the second line includes the species abundances for 37 species in the Logged treatment. **For each line, the first entry is the title of the dataset (the title is not allowed to start with a numerical digit) followed by the species abundances.** All entries should be separated by blank space (" "). For example, in the Girdled Treatment, the most abundant species is represented by 46 individuals, the second most abundant species is represented by 22 individuals in the sample, etc. Although the species abundances in this example are entered in a decreasing order, the ordering is not relevant in our analysis. You can choose any ordering of species abundances. 

* Import incidence data:
  We use the ant data at two elevations (the 1500m and 2000m elevations on the Barva Transect in northeastern Costa Rica from Longino and Colwell 2011) as an example:
  
  ```{r}
  Ants_1500m 200 144 113 79 76 74 73 53 50 43 33 32 30 29 25 25 25 24 23 23 19 18 17 17 11 11 9 9 9 9 6 6 5 5 5 5 4 4 3 3 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1
  Ants_2000m 200 80 59 34 23 19 15 13 8 8 4 3 2 2 1
  ```

The import data contain two lines (separated by return, "↵"), the first line includes ants data at 1500m elevation, and the second line includes ants data at 2000m elevation. ** For each line, the first entry is the title of the dataset (the title is not allowed to start with a numerical digit), the second entry is the total number of sampling units, followed by the species incidences abundances (the number of sampling units that each species is found). ** All element entries should be separated by blank space (" "). For example, at 1500m elevation, 200 sampling units were used. The most frequent species was found in 144 sampling units, the second most frequent species was found in 113 units, etc. Although the species incidences in this example are entered in a decreasing order, the ordering is not relevant in our analysis.
<h2 id="gen-settings">General settings</h2>
<h3 id="endpoint">Endpoint</h3>
The endpoint is a value specifying the sample size (number of individuals/sampling units) or sample coverage that is the endpoint for extrapolation. 

1. If only one dataset is selected for sample-size-based rarefaction/extrapolation, the default endpoint (that appears in the lower end of the slider-bar) is double the original sample size ( = reference sample size). For coverage-based rarefaction/extrapolation, the default endpoint (that appears in the lower end of the slider-bar) is the coverage associated with a doubling of the reference sample size. 

2. If multiple datasets are selected for comparison for sample-size-based rarefaction/extrapolation, then the default (that appears in the lower end of the slider-bar) is defined as “double the smallest reference sample size or the maximum reference sample size, whichever is larger”. This is referred to as“base sample size”in Chao et al. (2013). For  coverage-based rarefaction/extrapolation, the default (that appears in the lower end of the slider-bar) is defined as “the lowest coverage for doubled reference sample sizes or the maximum coverage for reference samples, whichever is larger”. This coverage is referred to as “base sample coverage” in Chao et al. (2013). 

The author can select any endpoint that is between the reference sample size (or reference sample coverage) to a large number sample size that corresponds to a maximum coverage of 99.9%. We suggest the user do not select an endpoint that goes too far from the recommended default (that appears in the lower end of the slider-bar). 

<h3 id="knots">Knots</h3>
Number of knots (say K, default is 40) is an integer specifying that the rarefaction part is divided as approximately K/2 equally spaced knots (sample sizes) between size 1 and the reference size, and the extrapolation part is also divided as approximately K/2 equally spaced knots (sample sizes) between the reference sample size and the endpoint. Each knot represents a sample size of a particular number of individuals for which the species richness estimate and its associated 95% confidence interval will be calculated. The default is 40, which locates the reference sample at the midpoint of the selected number of knots. If you choose a large number of knots (so that the plots will look smoother), you may need to wait for a long time to obtain output because the bootstrapping involved in the construction of confidence intervals (if your entry for number of bootstraps is not 0; see below) is time consuming.

<h3 id="bootstraps">Bootstraps</h3>
Number of bootstraps (say B) is an integer specifying the number of replications for bootstrap resampling scheme in computing variance and constructing 95% confidence intervals. Refer to Chao et al. (2013) for details. Default is 0 (it means that variances and confidence intervals will not be computed or plotted). To save running time, we recommend that 50 or 100 bootstraps will be sufficient for most applications.  

<h2 id="output">Output</h2>
<h3 id="summary">Data Summary</h3>
This tab panel shows basic data information for the selected data. The output variables are interpreted at the bottom of the tab panel. Click [Download as csv file]() to download the output summary.

<h3 id="inext">Rarefaction/Extrapolation</h3>
This tab panel shows the main output for iNEXT. The output variables are interpreted at the bottom of the tab panel. Click [Download as csv file]() to download the output table.

<h3 id="plot"> Figure Plots</h3>
This tab panel shows three species rarefaction/extrapolation curves (described in [Overview](#overview)). Click [Download as PDF]() to download any figure.
  
<h2 id="reference">References</h2>

1. Chao, A., N. J. Gotelli, T. C. Hsieh, E. L. Sander, K. H. Ma, R. K. Colwell, and A. M. Ellison 2013. Rarefaction and extrapolation with Hill numbers: a unified framework for sampling and estimation in biodiversity studies, Ecological Monographs (under revision).

2. Chao, A., and L. Jost. 2012. Coverage-based rarefaction and extrapolation: standardizing samples by completeness rather than size. Ecology 93:2533-2547.

3. Colwell, R. K., A. Chao, N. J. Gotelli, S. Y. Lin, C. X. Mao, R. L. Chazdon, and J. T. Longino. 2012. Models and estimators linking individual-based and sample-based rarefaction, extrapolation and comparison of assemblages. Journal of Plant Ecology 5:3-21.

4. Ellison, A. M., A. A. Barker-Plotkin, D. R. Foster, and D. A. Orwig. 2010. Experimentally testing the role of foundation species in forests: the Harvard Forest Hemlock Removal Experiment. Methods in Ecology and Evolution 1:168-179.

5. Hsieh, T. C., K. H. Ma, and A. Chao. 2013. iNEXT online: interpolation and extrapolation (Version 1.0) [Software]. Available from http://chao.stat.nthu.edu.tw/inext/.

6. Janzen, D. H. 1973a. Sweep samples of tropical foliage insects: effects of seasons, vegetation types, elevation, time of day, and insularity. Ecology 54:687-708.
  
7. Janzen, D. H. 1973b. Sweep samples of tropical foliage insects: description of study sites, with data on species abundances and size distributions. Ecology 54:659-686.

8. Longino, J. T., J. Coddington, and R. K. Colwell. 2002. The ant fauna of a tropical rain forest: estimating species richness three different ways. Ecology 83:689-702.

9. Longino, J. T., and R. K. Colwell. 2011. Density compensation, species composition, and richness of ants on a neotropical elevational gradient. Ecosphere 2:art29.

10. Sackett, T. E., S. Record, S. Bewick, B. Baiser, N. J. Sanders, and A. M. Ellison. 2011. Response of macroarthropod assemblages to the loss of hemlock (Tsuga canadensis), a foundation species. Ecosphere 2: art74.
