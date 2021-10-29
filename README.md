### Fiber direction strain heterogeneity

Repository for demons algorithm parameter analysis study.

[![](https://img.shields.io/badge/DATA%20DOI-10.17605%2FOSF.IO%2F2G9PH-blue)](https://doi.org/10.17605/OSF.IO/2G9PH) 

👆 You can click the badge above to access data (OSF).

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/HEAD/main?urlpath=notebooks) [![](https://img.shields.io/badge/Voila-Dashboard-red?style=flat&logo=jupyter)](https://mybinder.org/v2/gh/biyomekanik/heterogeneity/main?urlpath=%2Fvoila%2Frender%2Fnotebooks%2Fstep1_interactive_dashboard.ipynb)

👆 You can click the badges above reproduce statistical analyses & generate interactive figures in a web browser, no installation required.

## DATA ORGANIZATION & HIGH-LEVEL PROVENANCE RECORDS

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

 </details>
#### `Stats_derivatives` folder 

* step1_interactive_dashboard.ipynb

📁 Scripts in the `matlab` folder were executed on MATLAB R2019b, requires a local MATLAB installation. 

