function write_vtkFiberBundle(fibers,filename)

points = [];
for i = 1:length(fibers)
    points = [ points ; fibers(i).points ];
end

fid = fopen(filename,'wt');
%fid = fopen(filename,'w');
 fprintf(fid,'# vtk DataFile Version 3.0\nvtk output\nASCII\nDATASET POLYDATA\n');
 fprintf(fid,'POINTS %d float\n',size(points,1));
 %%%%
 for i = 1:length(points)
     fprintf(fid,'%3.7f %3.7f %3.7f\n',points(i,1),points(i,2),points(i,3));
 end
 
 fprintf(fid,'\nLINES %d %d\n',length(fibers),length(fibers) + size(points,1));
 n = 0;
 for i = 1:length(fibers)
     fprintf( fid, num2str( size( fibers(i).points, 1 ) ) );
     for j = 1:size( fibers(i).points, 1 )
         fprintf(fid, ' %d', n);
         n = n+1;
     end
     fprintf( fid, '\n');
 end
 
if isfield(fibers,'scalars')
     fprintf(fid,'\nPOINT_DATA %d\n',size(points,1));
     fprintf(fid,'SCALARS volume_scalars float 1\n');
     fprintf(fid,'LOOKUP_TABLE default\n');
     for i = 1:length(fibers)
         fprintf(fid, '%3.7f\n', fibers(i).scalars);
     end
 end

%{
fprintf(fid,'# vtk DataFile Version 4.2\n3D Slicer output. SPACE=RAS\nBINARY\nDATASET POLYDATA\n');
fprintf(fid,'POINTS %d float\n',size(points,1));
%%%%
for i = 1:length(points)
    fwrite(fid,points(i,:),'single',0,'b');
end

fprintf(fid,'\nLINES %d %d\n',length(fibers),length(fibers) + size(points,1));
n = 0;
for i = 1:length(fibers)
    fwrite(fid,size(fibers(i).points,1),'uint32',0,'b');
    for j = 1:size(fibers(i).points,1)
        fwrite(fid,n,'uint32',0,'b');
        n = n+1;
    end
end

if isfield(fibers,'scalars')
    fprintf(fid,'\nPOINT_DATA %d\n',size(points,1));
    fprintf(fid,'SCALARS volume_scalars float 1\n');
    fprintf(fid,'LOOKUP_TABLE default\n');
    for i = 1:length(fibers)
        fwrite(fid,fibers(i).scalars,'single',0,'b');
    end
end

%}

fclose(fid);

end
