
function parse_VTK_fibers(usrDir)

datDir = 'demons_param_data';
relDir = [datDir filesep 'StatsRaw' filesep 'JMRI' filesep 'VTK Fibers'];

mkdir([usrDir filesep datDir filesep 'StatsRaw' filesep 'JMRI' filesep 'MAT Fibers']);
subs =  [3 4 5 6 7];
alphas = [4 6 8 10];
sigmas = alphas;

for ii = 1:length(subs)

    for jj = 1:length(alphas)
        for kk =1:length(sigmas)
  eval(['S' num2str(subs(ii)) '_sigma' num2str(sigmas(kk)) '_alpha' num2str(alphas(jj)) '= read_vtkFiberBundle( '' '  usrDir filesep relDir filesep 's' num2str(subs(ii)) '_flx_pas_ext_pas_' num2str(sigmask(kk)) '_' num2str(alphas(jj)) '_fibers.vtk '' );']);     
        end
    end   
end


save([usrDir filesep datDir filesep 'StatsRaw' filesep 'JMRI' filesep 'MAT Fibers' filesep 'MatFibers.mat'])
disp(['DONE: ' usrDir filesep datDir filesep 'StatsRaw' filesep 'JMRI' filesep 'MAT Fibers']);
end