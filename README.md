## REPRODUCE THE ANALYSIS ONLINE 

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/HEAD?labpath=notebooks) [![](https://img.shields.io/badge/Voila-Dashboard-red?style=flat&logo=jupyter)](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/main?urlpath=%2Fvoila%2Frender%2Fnotebooks%2Fstep1_interactive_dashboard.ipynb)

👆 You can click the badges above to reproduce statistical analyses & generate interactive figures in a web browser. 
> No installation required. The dataset will be downloaded to the online runtime. 

## DATASET

[![](https://img.shields.io/badge/DATA%20DOI-10.17605%2FOSF.IO%2F2G9PH-blue)](https://doi.org/10.17605/OSF.IO/2G9PH) 

👆 You can click the badge above to access data (OSF), made publicly available under CC-BY 4.0 License. 

## DATA ORGANIZATION & REPRODUCIBILITY INSTRUCTIONS

<details>
<summary>🗂 <code>Stats_raw</code> folder </summary>
<hr>
  
* `FiberStrain_vtk` subfolder 
  * Reconstructed gastrocnemius medialis (GM) fascicles in physical coordinates, saved in `vtkPolyData` format (`*.vtk`) for 16 parameter combinations of all 5 subjects (A-E). Fiber direction strain values are written as scalars to fiber nodes (x,y,z).
  * Lowest level derived data provided. 
* `FiberStrain_mat` subfolder 
  * The `MatFibers.mat` file contains 80 struct arrays loaded into MATLAB by reading `*.vtk` files. The length of a struct array corresponds to number of fascicles tracked. Each fascicle is comprised of multiple nodes and for each node location (`.points` field), a fiber direction strain scalar (`.scalars`) is saved.
  * You can test `vtk` `mat` correspondance in MATLAB by:
    ```octave
        fibers = read_vtkFiberBundle('subA_flx_pas_ext_pas_4_4_fibers.vtk');
        load('MatFibers.mat');
        isequal(fibers, subA_sigma4-alpha_4);
    ```

 </details>

<details>
<summary>🗂 <code>Stats_derivatives</code> folder </summary>
<hr>
  
* `FiberStrain_parts` subfolder 
  * Stores 80 mat files, each containing 10 struct arrays for 10 muscle parts: `d1`, `d2`, `d3`, `d4`, `m1`, `m2`, `p4`, `p3`, `p2`, `p1`. Each muscle part contains different number of structs depending on how many fascicles does the respective plane intersect. The same nodal representation (`points (x,y,z)` and `scalar (strain)`) is followed.
  * ♻️ To re-generate muscle parts in MATLAB:
    * 1. Run the very top [section](https://www.mathworks.com/help/matlab/matlab_prog/create-and-run-sections.html;jsessionid=9eda978209027f28b3ec6573fe06) (`main.m`) **after** setting the directory where you downloaded the `Stats_raw` folder:
      ```octave
        %% ======================
        %  SET DATA (ROOT) DIRECTORY SECTION
        %  ======================
        rootDir = "/path/to/Stats_raw_folder";
      ```
      > Sections in matlab are executed by 
    * 2. Run `SECTION - 1` of the `main.m` script in MATLAB:
    ```octave
      %% ===========
      %  SECTION - 1 | Split tracked fascicles
      %  ===========
    ```
  * Heatmaps are located in this directory:
    * `sub-x_CentralTendency_median.png` Median fiber direction strain at each muscle part (Figures in the article). 
    * `sub-x_CentralTendency.png` Mean fiber direction strain at each muscle part (supplementary). 
    * `sub-x_Dispersion_mad.png` Median absolute deviation at each muscle part (supplementary). 
    * `sub-x_Dispersion.png` Standard deviation at each muscle part (supplementary).
  * ♻️ To re-generate heatmaps:
      * Run `SECTION - 2` of the `main.m` script in MATLAB with the following configuration:
      ```octave
        %% ===========
        %  SECTION - 2
        %  ===========
        ENABLE_STANDARDIZATION = false;
        WRITE_HEATMAPS = true;
      ```
* `FiberStrain_mzscore` subfolder 
  * Stores 80 mat files, each containing 10 struct arrays for 10 muscle parts: `d1`, `d2`, `d3`, `d4`, `m1`, `m2`, `p4`, `p3`, `p2`, `p1`. Each muscle part contains different number of structs depending on how many fascicles does the respective plane intersect. The scalars represent **modified z-score (mzscore)** of fiber direction strain distributions.
    * ♻️ To re-generate `_modzscore` fascicles and respective heatmaps:
      * Run `SECTION - 2` of the `main.m` script in MATLAB with the following configuration:
      ```octave
        %% ===========
        %  SECTION - 2
        %  ===========
        ENABLE_STANDARDIZATION = true;
        WRITE_HEATMAPS = true;
      ```
* `FiberStrain_mzscore_reduced` subfolder 
  * Modified z-score fascicles in 10 muscle parts after interval down-sampling (1400 nodes per part).
      * ♻️ To re-generate interval subsampled`_modzscore` fascicles:
        * Run `SECTION - 3` of the `main.m` script in MATLAB with the following configuration:
        ```octave
          %% ====================
          %  SECTION - 3
          %  UNIFORM DOWNSAMPLING
          %  ====================
          % MATLAB's default random number generator configs are used (rng(default)). 
          % Randomization is only applied when further reduction is needed. 
        ```
* `Static_from_3DSlicer` subfolder 
  * Screenshots (Figure-1) of fiber direction strain distributions for equal sigma and alpha binary pairs.
* `HSF_Inputs` subfolder 
  * Permutations of `{4,4}`,`{6,6}`,`{8,8}`,`{10,10}` configurations are parsed for hierarchical shift function analysis, to be performed in `R`.
    * `subX_reduced_aa_bb.file` R compatible (feather) data structure for HSF inputs comparing `{a,a}` vs `{b,b}` configurations of modified-z-score-reduced points clouds across muscle parts in a hierarchical statistical design (of dependent measurements, i.e. parameter alterations create dependent measurements). 
    * ♻️ To regenerate these files:
      * You can execute [`step2_parse_HSF_feather.ipynb`](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/HEAD?labpath=notebooks%2Fstep2_parse_HSF_feather.ipynb) online by following the instructions in the notebook. 
      * To execute locally, please ensure that following Python (>=3.6) dependencies are met: 
      ```python
        from scipy.io import loadmat
        import numpy as np
        import feather
        import pandas as pd
      ```
* `HSF_Inputs/HSF_Objects` sub-subfolder 
  * `subX_HSF_aa_bb.file` R data structure storing an R object generated by the hierarchical shift function analysis for the `{a,a}` vs `{b,b}` comparison across 10 muscle parts.
     * ♻️ To regenerate these files:
      * You can execute [`step3_runHSF_and_visualize.ipynb`](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/HEAD?labpath=notebooks%2Fstep3_runHSF_and_visualize.ipynb) online by following the instructions in the notebook. 
      * To execute locally, please ensure that following R (>=3.6) dependencies are met: 
      ```R
        install.packages(c('repr', 'IRdisplay', 'pbdZMQ', 'devtools'))  
        install.packages("ggplot2")
        install.packages("tibble")
        install.packages("gridextra")
        install.packages("R.matlab")
        install.packages("plotly")
        install.packages("plyr")
        install.packages("cowplot")
        install.packages("feather")
        install.packages("ggridges")
        install.packages("htmlwidgets")
        install.packages(c('repr', 'IRdisplay', 'pbdZMQ', 'devtools'))
        devtools::install_github('IRkernel/IRkernel')
        devtools::install_github('GRousselet/rogme')
      ```
  
 </details>
 
 ## TO WORK WITH THIS REPOSITORY ON YOUR COMPUTER
1. Clone this repository 
   ```
   git clone https://github.com/biyomekanik/heterogeneity.git
   ```
2. [Download](https://osf.io/2g9ph/) the dataset.  

3. Scripts in the `matlab` folder were executed on MATLAB R2019b, requires a local MATLAB installation. 
  * Octave compatibility is not ensured. 

4. To execute Jupyter Notebooks on your computer:
  * Make sure that [R](https://www.r-project.org/) (>=3.6) and [Python](https://www.anaconda.com/) (>=3.6) are installed 
  * Make sure that the dependencies listed in the `Stats_derivatives` section above are met for both Octave and Python. 
