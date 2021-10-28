% Quick and dirty vtk fiber generator

function quick_vtk_fibers(inFib)

    % [file,path] = uigetfile('*.txt','Coords');
    % cd(path);
    % coords = load_sparse_data(file, 1);
    % 
    % 
    % [file,path] = uigetfile('*.txt','STR_stat');
    % cd(path);
    % strains = load_sparse_data(file, 2);

    
    x=0;y=0;z=0;str=0;
    disp('Gimme ma fibers..');
    for i=1:length(inFib)
       
        
      if not(isequal(size(inFib(i).points),[0,0]))
      
      %Binary fiber section start 
      %lenlen = find(strains(i).mat>0);
      %strains(i).mat(lenlen) = 255;
      
      %shosho = find(strains(i).mat<=0);
      %strains(i).mat(shosho) = 0;    
      %Binary fiber section end 
          
      x=[x;inFib(i).points(:,1)];
      y=[y;inFib(i).points(:,2)];
      z=[z;inFib(i).points(:,3)];
      str=[str;inFib(i).scalars];
      end
      
    end
    
    x(1)=[];
    y(1)=[];
    z(1)=[];
    str(1)=[];
    
    disp('Here you are');
    path3D=[x y z str];
    export3Dline2VTK('TEST',path3D);
    
    end
    