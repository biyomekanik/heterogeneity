function splitin10(inFib,outDir)

varName = inputname(1);
disp(['Running for: ' varName]);

% Number of fibers in the bundle     
lenstr = length(inFib);

% Each indexed constituent of spatial segments (p, m, d) contains NODAL
% locations and scalars.   


% Init vars to store scalars per region 
p1.scalars = []; p1.points = p1.scalars;
p2.scalars = []; p2.points = p2.scalars;
p3.scalars = []; p3.points = p3.scalars;
p4.scalars = []; p4.points = p4.scalars;
m1.scalars = []; m1.points = m1.scalars;
m2.scalars = []; m2.points = m2.scalars;
d1.scalars = []; d1.points = d1.scalars;
d2.scalars = []; d2.points = d2.scalars; 
d3.scalars = []; d3.points = d3.scalars;
d4.scalars = []; d4.points = d4.scalars;

% Init vars to store 
minos = zeros(lenstr,1);
maxos = zeros(lenstr,1);

for i=1:lenstr
   
    curfiberlength = length(inFib(i).points);
    minos(i,1) = min(inFib(i).points(:,3));
    maxos(i,1) = max(inFib(i).points(:,3));
    
end

minz = min(minos);
maxz = max(maxos);

zlocvec = linspace(minz,maxz,11);

for i=1:lenstr

        curfiberlength = length(inFib(i).scalars);

        if not(isempty(find(inFib(i).points(:,3)<zlocvec(2)))) % THE MOST DISTAL
        idx1 = find(inFib(i).points(:,3)<zlocvec(2));
        d4.scalars = [d4.scalars;inFib(i).scalars(idx1,1)];
        d4.points = [d4.points;inFib(i).points(idx1,:)];

        
        % Comment-in the following line to manipulate scalars for sanity check.
        %inFib(i).scalars(idx1,1) = 0;
        
        end
        
        if not(isempty(find(inFib(i).points(:,3)>zlocvec(2) & inFib(i).points(:,3)<zlocvec(3))))
        idx2 = find(inFib(i).points(:,3)>zlocvec(2) & inFib(i).points(:,3)<zlocvec(3));
        d3.scalars = [d3.scalars;inFib(i).scalars(idx2,1)];
        d3.points = [d3.points;inFib(i).points(idx2,:)];

        % Comment-in the following line to manipulate scalars for sanity check.
        %inFib(i).scalars(idx2,1) = 10;
       
        end
        
        if not(isempty(find(inFib(i).points(:,3)>zlocvec(3) & inFib(i).points(:,3)<zlocvec(4))))
        idx3 = find(inFib(i).points(:,3)>zlocvec(3) & inFib(i).points(:,3)<zlocvec(4));
        d2.scalars = [d2.scalars;inFib(i).scalars(idx3,1)];
        d2.points = [d2.points;inFib(i).points(idx3,:)];

        % Comment-in the following line to manipulate scalars for sanity check.
        %inFib(i).scalars(idx3,1) = 20;

        end
        
        if not(isempty(find(inFib(i).points(:,3)>zlocvec(4) & inFib(i).points(:,3)<zlocvec(5))))
        idx4 = find(inFib(i).points(:,3)>zlocvec(4) & inFib(i).points(:,3)<zlocvec(5));
        d1.scalars = [d1.scalars;inFib(i).scalars(idx4,1)];
        d1.points = [d1.points;inFib(i).points(idx4,:)];

        
        % Comment-in the following line to manipulate scalars for sanity check.
        %inFib(i).scalars(idx4,1) = 30;

        end
        
        if not(isempty(find(inFib(i).points(:,3)>zlocvec(5) & inFib(i).points(:,3)<zlocvec(6)))) 
        idx5 = find(inFib(i).points(:,3)>zlocvec(5) & inFib(i).points(:,3)<zlocvec(6));
        m2.scalars = [m2.scalars;inFib(i).scalars(idx5,1)];
        m2.points = [m2.points;inFib(i).points(idx5,:)];

        % Comment-in the following line to manipulate scalars for sanity check.
        %inFib(i).scalars(idx5,1) = 40;

        end

        if not(isempty(find(inFib(i).points(:,3)>zlocvec(6) & inFib(i).points(:,3)<zlocvec(7)))) 
            idx6 = find(inFib(i).points(:,3)>zlocvec(6) & inFib(i).points(:,3)<zlocvec(7));
            m1.scalars = [m1.scalars;inFib(i).scalars(idx6,1)];
            m1.points = [m1.points;inFib(i).points(idx6,:)];

            % Comment-in the following line to manipulate scalars for sanity check.
            %inFib(i).scalars(idx6,1) = 50;

        end

        if not(isempty(find(inFib(i).points(:,3)>zlocvec(7) & inFib(i).points(:,3)<zlocvec(8)))) 
            idx7 = find(inFib(i).points(:,3)>zlocvec(7) & inFib(i).points(:,3)<zlocvec(8));
            p1.scalars = [p1.scalars;inFib(i).scalars(idx7,1)];
            p1.points = [p1.points;inFib(i).points(idx7,:)];

            % Comment-in the following line to manipulate scalars for sanity check.
           % inFib(i).scalars(idx7,1) = 60;

        end

        if not(isempty(find(inFib(i).points(:,3)>zlocvec(8) & inFib(i).points(:,3)<zlocvec(9)))) 
            idx8 = find(inFib(i).points(:,3)>zlocvec(8) & inFib(i).points(:,3)<zlocvec(9));
            p2.scalars = [p2.scalars;inFib(i).scalars(idx8,1)];
            p2.points = [p2.points;inFib(i).points(idx8,:)];

            % Comment-in the following line to manipulate scalars for sanity check.            
            %inFib(i).scalars(idx8,1) = 70;

        end

        if not(isempty(find(inFib(i).points(:,3)>zlocvec(9) & inFib(i).points(:,3)<zlocvec(10)))) 
            idx9 = find(inFib(i).points(:,3)>zlocvec(9) & inFib(i).points(:,3)<zlocvec(10));
            p3.scalars = [p3.scalars;inFib(i).scalars(idx9,1)];
            p3.points = [p3.points;inFib(i).points(idx9,:)];

            % Comment-in the following line to manipulate scalars for sanity check.
           % inFib(i).scalars(idx9,1) = 80;

        end

        if not(isempty(find(inFib(i).points(:,3)>zlocvec(10) & inFib(i).points(:,3)<zlocvec(11)))) 
            idx10 = find(inFib(i).points(:,3)>zlocvec(10) & inFib(i).points(:,3)<zlocvec(11));
            p4.scalars = [p4.scalars;inFib(i).scalars(idx10,1)];
            p4.points = [p4.points;inFib(i).points(idx10,:)];
            
            % Comment-in the following line to manipulate scalars for sanity check.
            %inFib(i).scalars(idx10,1) = 90; % THE MOST PROXIMAL 

        end

      

end


 %write_vtkFiberBundle(inFib,'s3test.vtk');
 
 save([outDir filesep varName '_seg10' '.mat'], 'p1','p2','p3','p4','m1','m2','d1','d2','d3','d4');

end










