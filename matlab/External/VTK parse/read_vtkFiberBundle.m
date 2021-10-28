function fibers = read_vtkFiberBundle(filename)

if(exist('filename','var')==0)
    [filename, pathname] = uigetfile('*.vtk', 'Read vtk-file');
    filename = [pathname filename];
end

fid=fopen(filename,'rb');
if(fid<0)
    fprintf('could not open file %s\n',filename);
    return
end

str = fgetl(fid);
info.Filename=filename;
info.Format=str(3:5); % Must be VTK
info.Version=str(end-2:end);
info.Header = fgetl(fid);
info.DatasetFormat= lower(fgetl(fid));
str = lower(fgetl(fid));
info.DatasetType = str(9:end);

if ~strcmp(lower(info.DatasetType),'polydata')
    
    if strcmp(lower(info.DatasetType),'unstructured_grid')
        disp('Unstructured grid')
    else
        disp('ERROR: Unrecognized vtk data type');
        return
    end
end

while ~feof(fid)
    str=lower(fgetl(fid));
    % 1. Read Geometry/topology ***********************
    % Point data --------------------------------
    if (strfind(str,'points'))
        [tmp1, tmp2] = strtok(str);
        [tmp1, tmp2] = strtok(tmp2);
        npoints = str2num(tmp1);
        mesh.npoints = npoints;
        p = zeros(npoints,3);
        
        [num]=fread(fid,3*npoints,'float=>float',0,'b');
        index=1;
        for i = 1:npoints
            p(i,1)=   num(index);
            index=index+1;
            p(i,2)=   num(index);
            index=index+1;
            p(i,3)=   num(index);
            index=index+1;
        end
        mesh.points = p;
        clear p;

    elseif (strfind(str,'lines'))
        [tmp1, tmp2] = strtok(str);
        [tmp1, tmp2] = strtok(tmp2);
        nlines = str2num(tmp1);
        ndata = str2num(tmp2);
        mesh.nlines = nlines;
        mesh.lines = cell(nlines,1);
        for i = 1:nlines
            num = fread(fid,1,'uint32=>uint32',0,'b');
            [num] = fread(fid,num,'uint32=>uint32',0,'b');
            mesh.lines{i} = num;
        end        
        % 2. Read Dataset attributes ********************
        % Point data --------------------------------//////////////
    elseif (strfind(str,'point_data'))
        [tmp1, tmp2] = strtok(str);
        [tmp1, tmp2] = strtok(tmp2);
        npoint_data = str2num(tmp1);
        
        str = lower(fgetl(fid));
        tmp = split(str);
        if strcmp(tmp{1},'scalars')
            mesh.nscalars = npoint_data;
            mesh.scalarname = tmp{2};
            fgetl(fid);
            mesh.scalars=fread(fid,npoints,'float=>float',0,'b');
            
        elseif strcmp(tmp{1},'tensors')
            mesh.ntensors = npoint_data;
            mesh.tensorname = tmp{2};
            mesh.tensors = zeros([size(mesh.points) 3]);
            
            [num]=fread(fid,9*npoints,'float=>float',0,'b');
            for i = 1:npoint_data
                mesh.tensors(i,:,:) = reshape(num(9*i-8:9*i),3,3);
            end
        end         
        % end of reading point data ----------------------/////////
    end
end
fclose(fid);

fibers = struct([]);

if isfield(mesh,'scalars')
    for i = 1:mesh.nlines
        fibers(i).points = mesh.points(mesh.lines{i}+1,:);
        fibers(i).scalars = mesh.scalars(mesh.lines{i}+1);
    end
else
    for i = 1:mesh.nlines
        fibers(i).points = mesh.points(mesh.lines{i}+1,:);
    end
end    

end
