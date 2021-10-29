%% BEFORE YOU START
%
% 1) Please make sure that src and External folders and all their contents 
%    are added to your MATLAB search path. 
%
% 2) Download the required data and set rootDir. Please see the 
%    following section for details.
%    - The dataset is available at https://osf.io/dycgp/
%                                  CC-BY-4.0 LICENSE
%
% 3) Please run sections in the following order: 
%
%        - SET DATA (ROOT) DIRECTORY       To read input data and organize
%                                          outputs.
%                                                       
%        - SECTION 1                       Split tracked fascicles into 
%                                          muscle parts and save outputs.
%
%        - SECTION 2                       Calculate modified z-scores,
%                                          reconstruct heatmaps for
%                                          selected statistics and save
%                                          outputs.
%
%        - SECTION 3                       Uniform downsample the
%                                          modified z-score standardized
%                                          data and save outputs.
%
%        - SECTION 4                       Reconstruct a heatmap showing
%                                          number of significantly
%                                          different pairwise
%                                          (Kruskal-Wallis followed by Dunn
%                                          Sidak) comparisons at each muscle
%                                          part.
%
% With this script, you can re-generate all the outputs in the 
% Stats_derivatives folder, which are provided in the OSF repository as well. 
% 
% 
% Please visit the notebooks folder to re-generate outputs from
% higher-level statistical analyses (HSF) and interactive visualizations. 
% 
% ------------------------------------------------------------------------
% Written by: Agah Karakuzu
% ------------------------------------------------------------------------
%% ======================
%  SET DATA (ROOT) DIRECTORY
%  ======================

% IMPORTANT
% ---------
% To run this script, the root directory should at least contain
% the Stats_raw directory that stores MatFibers.mat file. 

% VTK Fibers 
% ----------
% Fibers in VTK format are available on OSF repository. MatFibers.mat stores
% all 80 vtk fibers in struct format. You can use a vtk compatible viewer
% such as 3D slicer to see the strain encoded fibers or load them into 
% matlab using: 
%
% ```
%   fibers = read_vtkFiberBundle('subA_flx_pas_ext_pas_4_4_fibers.vtk');
%   load('MatFibers.mat');
%   isequal(fibers, subA_sigma4-alpha_4);
% ```
% You can use point cloud tools (in the External folder) to visualize mat 
% fibers in 3D in MATLAB. 

% IMPORTANT:
% Please assign rootDir variable to the parent directory that 
% contains Stats_raw (required) and Stats_derivatives (optional)
% folder.

rootDir = '/Users/agah/Desktop/boun-parametre/demons_data_clean2';

statsRawDir = [rootDir filesep 'Stats_raw'];
matFibersFile = [statsRawDir filesep 'FiberStrain_mat' filesep 'MatFibers.mat'];

statsDerDir = [rootDir filesep 'Stats_derivatives'];
segFibersDir = [statsDerDir filesep 'FiberStrain_parts'];

mzsFibersDir = [statsDerDir filesep 'FiberStrain_mzscore'];
mzsRedFibersDir = [statsDerDir filesep 'FiberStrain_mzscore_reduced'];
%% ===========
%  SECTION - 1 | Split tracked fascicles
%  ===========
%
%  This section is responsible with splitting strain encoded tracked
%  fascicles into 10 equal parts in the longitudinal axis:
%
%  Proximal ------------------------ p4 [purple]
%                                  - p3    |
%                                  - p2    |
%                                  - p1    |
%  Medial   ------------------------ m1 [orange]
%                                  - m2    |
%                                  - d1    |
%                                  - d2    |
%                                  - d3    |
%  Distal   ------------------------ d4 [green]
%
% Input:
%   ~/StatsRaw/MatFibers.mat        A large *.mat file that stores point
%                                   cloud information [x,y,z,strain] for
%                                   every fiber node of all subjects and
%                                   all the parameter combinations.
%                                   (16X5) 80 struct arrays with each struct
%                                   containing the fields of:
%                                       - points  [nNodes x 3] Locations
%                                       - scalars [nNodes x 1] Strain
%
% Output:
%   Files in *.mat format           S#_sigma#_alpha_seg10.mat
%                                   Each file contains point clouds for a
%                                   given parameter combination at 10
%                                   muscle parts.
%
%   Directory                       FiberStrain_segmented
% -------------------------------------------------------------------------

disp('Starting section 1...');
%  Please ensure that the directory variables are in 
%  your workspace. If not revisit SET ROOT DIRECTORY section.


if exist(statsDerDir,'dir')~=7
    mkdir(statsDerDir);
end
if exist(segFibersDir,'dir')~=7
    mkdir(segFibersDir);
end

% Load mat file
load(matFibersFile);

subs =  [{'subA'},{'subB'},{'subC'},{'subD'},{'subE'}];
alphas = [4 6 8 10];
sigmas = alphas;

for ii = 1:length(subs)
    for jj = 1:length(alphas)
        for kk =1:length(sigmas)
            % prototype: splitin10(struct_array_of_fibers,outputdirectory)
            eval(['splitin10(' subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) ' ,''' segFibersDir ''');']);
        end
    end
end

%% ============
%  SECTION - 2
%% ============
%  Save heatmaps. 
%  Please ensure that the directory variables are in 
%  your workspace. If not revisit SET ROOT DIRECTORY section.

disp('Starting section 2...');

if exist(mzsFibersDir,'dir')~=7
    mkdir(mzsFibersDir );
end

%  If ENABLE_STANDARDIZATION is set to true, modified z-score outputs will
%  be saved. To save heatmaps of median and MAD, set WRITE_MEDIAN_HEATMAPS
%  to true.
%  Default settings to reproduce the figures:
%  - ENABLE_STANDARDIZATION = true (will save modified z-scored dists)
%  - WRITE_HEATMAPS = true (will save heatmaps with meadian/MAD) 


ENABLE_STANDARDIZATION = false;
WRITE_HEATMAPS = true;

% If ENABLE_STANDARDIZATION is set to false, and WRITE_HEATMAPS is true, 
%ONLY median and MAD heatmaps for the original distribution will be saved.

% Initialize heatmaps and read data. ---------------------------------------
regs  = [{'p4'} {'p3'} {'p2'} {'p1'} {'m1'} {'m2'} {'d1'} {'d2'} {'d3'} {'d4'}];

heatmapM = zeros(16 , 10);
heatmapS = heatmapM;

subs =  [{'subA'},{'subB'},{'subC'},{'subD'},{'subE'}];
alphas = [4 6 8 10];
sigmas = alphas;

for ii = 1:length(subs)
    iter = 1;
    for jj = 1:length(alphas)
        for kk =1:length(sigmas)
            
            % These could have been loaded in structs and I am aware that 
            % the eval calls are not elegant, however people find it easier
            % to see variables appearing in the workspace. That's I used 
            % eval calls so often.
            eval(['load(' '''' segFibersDir filesep subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '_seg10.mat''' ');']);
            
            if ENABLE_STANDARDIZATION
                
                % Pool the segment data and index for standardization.                
                pool = [p4.scalars;p3.scalars;p2.scalars;p1.scalars;m1.scalars;...
                    m2.scalars;d1.scalars;d2.scalars;d3.scalars;d4.scalars];
                
                % Perform modified z-score normalization. This method is more robust against
                % outliers. Standard scaling normalizes data to a small interval in the presence
                % of outliers and asymmetrical distributions.
                
                med = median(pool);
                % Second argument for mad: 
                %   - 1: Median Absolute Deviation
                %   - 2: Mean Absolute Deviation
                MAD = mad(pool,1);
                meanAD = mad(pool,0);
                % More commonly, the multiplicative factor 
                % is given in the numarator (0.6745), here
                % it is controlled for the cases MAD equals 0. Rounded to 
                % two significant digits.
                
                if round(MAD,2) == 0
                    pool = (pool-med)./(1.253314*meanAD);
                else
                    pool = (pool-med)./(1.4826*MAD);
                end
                
                lp4 = length(p4.scalars);
                lp3 = length(p3.scalars);
                lp2 = length(p2.scalars);
                lp1 = length(p1.scalars);
                lm1 = length(m1.scalars);
                lm2 = length(m2.scalars);
                ld4 = length(d4.scalars);
                ld3 = length(d3.scalars);
                ld2 = length(d2.scalars);
                ld1 = length(d1.scalars);
                
                % Explicit indexing for reader's convience
                p4.scalars = pool(1:lp4);
                p3.scalars = pool(lp4+1:lp4+lp3);
                p2.scalars = pool(lp4+lp3+1:lp4+lp3+lp2);
                p1.scalars = pool(lp4+lp3+lp2+1:lp4+lp3+lp2+lp1);
                m1.scalars = pool(lp4+lp3+lp2+lp1+1:lp4+lp3+lp2+lp1+lm1);
                m2.scalars = pool(lp4+lp3+lp2+lp1+lm1+1:lp4+lp3+lp2+lp1+lm1+lm2);
                d1.scalars = pool(lp4+lp3+lp2+lp1+lm1+lm2+1:lp4+lp3+lp2+lp1+lm1+lm2+ld1);
                d2.scalars = pool(lp4+lp3+lp2+lp1+lm1+lm2+ld1+1:lp4+lp3+lp2+lp1+lm1+lm2+ld1+ld2);
                d3.scalars = pool(lp4+lp3+lp2+lp1+lm1+lm2+ld1+ld2+1:lp4+lp3+lp2+lp1+lm1+lm2+ld1+ld2+ld3);
                d4.scalars = pool(lp4+lp3+lp2+lp1+lm1+lm2+ld1+ld2+ld3+1:end);
                
                for reg_iter = 1:length(regs)
                    
                    
                    % CENTRAL TENDENCY
                    % Run the following line instead of the one after to
                    % save heatmaps showing mean values. Note that this is 
                    % more susceptible to the outlier/skewness effects.
                    
                    % eval(['heatmapM(iter , reg_iter) = mean(' regs{reg_iter} '.scalars);']);
                    
                    eval(['heatmapM(iter , reg_iter) = median(' regs{reg_iter} '.scalars);']);
                    
                    % DISPERSION
                    
                    % Run the following line instead of the one after to
                    % save heatmaps showing STD values. Note that this is 
                    % more susceptible to the outlier/skewness effects.
                    
                    % eval(['heatmapM(iter , reg_iter) = std(' regs{reg_iter} '.scalars);']);
                    
                    eval(['heatmapS(iter , reg_iter) = abs(mad(' regs{reg_iter} '.scalars)./median(' regs{reg_iter} ' .scalars,1));']);
                    
                end
                
                % Save fibers with modified z-scores.
                iter = iter+1;
                save([mzsFibersDir filesep subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '_modzscore.mat'],'p4','p3','p2','p1','m1','m2','d1','d2','d3','d4','pool');
                
                heatmapPath = mzsFibersDir;
            end % END OF if ENABLE_STANDARDIZATION
            
            if ~ENABLE_STANDARDIZATION
                
                % Heatmaps from the original distribution will be saved in the same folder
                % with the original data (segFibersDir)
                
                heatmapPath = segFibersDir;
                
                % Fill out heatmaps with simple summary statistics from the original distribution.
                
                for reg_iter = 1:length(regs)
                    % CENTRAL TENDENCY
                    % Sigma inner and alpha is outer in the nested loop, so
                    % the order is:
                    % Sigma |4|6|8|10|4|6|8|10|...
                    % Alpha |4|4|4|4 |6|6|6|6 |...
                    
                    eval(['heatmapM(iter , reg_iter) = median(' regs{reg_iter} '.scalars);']);
                    
                    % DISPERSION
                    
                    eval(['heatmapS(iter , reg_iter) = mad(' regs{reg_iter} '.scalars,1);']);
                    
                end
                iter = iter+1; % See L183
            end
            
        end % END OF THE INNER LOOP (kk) sigmas iter
        
    end % END OF THE INNER LOOP (jj) alphas iter
    
    % Write heatmaps in PNG format. -------------------------------------------
    
    if WRITE_HEATMAPS
        
        
        figure();
        for tt=1:16
            clabel = arrayfun(@(x){sprintf('%0.2f',x)}, heatmapM(tt,:)');
            subplot(1,16,tt); heatmap_ext(heatmapM(tt,:)',[],[],clabel); colormap(redblue);
            ax = gca;
            set(ax,'XTick',[], 'YTick', []);
        end
        if ENABLE_STANDARDIZATION
            title(ax,'Median of modified z-scores');
        else
            title(ax,'Mean fiber direction strain (over parts)');
        end
        set(gcf,'color','k');
        saveas(ax,[heatmapPath filesep subs{ii} '_CentralTendency.png']);
        
        figure();
        for tt=1:16
            clabel = arrayfun(@(x){sprintf('%0.2f',x)}, heatmapS(tt,:)');
            subplot(1,16,tt); heatmap_ext(heatmapS(tt,:)',[],[],clabel); colormap(redblue);
            ax = gca;
            set(ax,'XTick',[], 'YTick', []);
        end
        if ENABLE_STANDARDIZATION
            title(ax,'Median absolute deviation within parts');
        else
            title(ax,'Standard deviation within parts');
        end
        set(gcf,'color','k');
        saveas(gcf,[heatmapPath filesep subs{ii} '_Dispersion.png']);

        
    end
    
end % END OF THE MAIN LOOP (ii) subject iter

disp('DONE...');
%% ====================
%  SECTION - 3
%  UNIFORM DOWNSAMPLING
%  ====================
%  Please ensure that the directory variables are in 
%  your workspace. If not revisit SET ROOT DIRECTORY section.

% You can re-generate outputs in the Fibers_mzscore_reduced using this section.

% WARNING:
%   Please make sure that you don't have any variables in the workspace,
%   otherwise they may have been overwritten (e.g. p4, p3, ...)

% WARNING:
%   This process may take some time as it'll be iterating over 800 segments
%   (16 X 10 X 5) for interval downsampling.

disp('Starting section 3...');

if exist(mzsRedFibersDir,'dir')~=7
    mkdir(mzsRedFibersDir);
end


% WARNING:
%   Verbose output due to point cloud tools for MATLAB.

% WARNING:
%   Setting DISPLAY to true is NOT RECOMMENDED for this section. The DISPLAY
%   argument in the pc_reduce function is intended for individual function
%   calls.
DISPLAY = false;

% WARNING
%   The selection of 1400 is based on the number of samples in the S7-d4
%   pointcloud. Any value higher than 1492 will throw an error eventually.

NUMBER_POINTS = 1400;

subs =  [{'subA'},{'subB'},{'subC'},{'subD'},{'subE'}];
alphas = [4 6 8 10];
sigmas = alphas;

for ii = 1:length(subs)
    for jj = 1:length(alphas)
        for kk =1:length(sigmas)
            
            
            curFile_read = [mzsFibersDir filesep subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '_modzscore.mat'];
            
            reduced_segments = pc_reduce(curFile_read,NUMBER_POINTS,DISPLAY);
            
            curFile_save =  [mzsRedFibersDir filesep subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '_modzscore_reduced.mat'];
            
            p4 = reduced_segments.p4;
            p3 = reduced_segments.p3;
            p2 = reduced_segments.p2;
            p1 = reduced_segments.p1;
            m1 = reduced_segments.m1;
            m2 = reduced_segments.m2;
            d1 = reduced_segments.d1;
            d2 = reduced_segments.d2;
            d3 = reduced_segments.d3;
            d4 = reduced_segments.d4;
            
            save(curFile_save,'p4','p3','p2','p1','m1','m2','d1','d2','d3','d4');
            
            
        end
    end
    
end

disp('DONE...');

%% =========
%  SECTION 4
%  =========
%  Please ensure that the directory variables are in 
%  your workspace. If not revisit SET ROOT DIRECTORY section.

% WARNING 
% This section uses implicit expansion, therefore may not be 
% compatible with MATLAB versions older than R2016b.

% Kruskal-Wallis followed by Dunn-Sidak across muscle parts per
% parameter combination pair. Number of significantly different pairwise
% comparisons are reconstructed as (copper) heatmaps. The purpose of this 
% test is to explore whether parameter combinations systematically modify
% the heterogeneity of fiber direction strains to a significant degree.

disp('Starting section 4...');

anovaTable = zeros(1400 , 10);
heatmapMC = zeros(16 , 10);

subs =  [{'subA'},{'subB'},{'subC'},{'subD'},{'subE'}];
alphas = [4 6 8 10];
sigmas = alphas;

for ii = 1:length(subs)
    iter = 1;
    
    for jj = 1:length(alphas)
        for kk =1:length(sigmas)
         
  eval(['load(''' mzsRedFibersDir filesep subs{ii} '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '_modzscore_reduced.mat'');']);     

        anovaTable(: ,1) = randsample(p4.scalars, 1400);
        anovaTable(: ,2) = randsample(p3.scalars, 1400);
        anovaTable(: ,3) = randsample(p2.scalars, 1400);
        anovaTable(: ,4) = randsample(p1.scalars, 1400);
        anovaTable(: ,5) = randsample(m1.scalars, 1400);
        anovaTable(: ,6) = randsample(m2.scalars, 1400);
        anovaTable(: ,7) = randsample(d1.scalars, 1400);
        anovaTable(: ,8) = randsample(d2.scalars, 1400);
        anovaTable(: ,9) = randsample(d3.scalars, 1400);
        anovaTable(: ,10) = randsample(d4.scalars, 1400);

        [p,tbl,stats] = kruskalwallis(anovaTable,[],'off');
        
        [c,m,h,nms] = multcompare(stats,'display','off','CType','dunn-sidak','Alpha',0.05);
        
        % First two column of c are comparison group IDS and the last one
        % contains p values. As the values are adjusted for multiple
        % comparison, for the specified alpha, count the number of
        % significant pairwise comparisons based on this threshold. 
        for tt = 1:10    
            heatmapMC(iter,tt) = sum(sum(c(:,1:2) == tt & c(:,6)<0.05,2));
        end    
        
        iter = iter + 1;
        
       end
    end


figure();
heatmap_ext(heatmapMC',[],[],'%d'); title([subs{ii} ' Multiple Comparison N different'])
colormap('copper'); colorbar; set(gcf,'color','k'); caxis([0 9]);
saveas(gcf,[mzsRedFibersDir filesep subs{ii} 'MultComp_dunn.png']);
c = colorbar;
c.Color = 'w';
ax = gca;% Get handle to current axes.
ax.XColor = 'k'; % Red
ax.YColor = 'k'; % Blue
clf;
end

disp('DONE');