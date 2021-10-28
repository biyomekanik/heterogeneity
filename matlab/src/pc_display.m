function pc_display(segment_fibers,scaleby)

    segments = load(segment_fibers);

    regs  = [{'p4'} {'p3'} {'p2'} {'p1'} {'m1'} {'m2'} {'d1'} {'d2'} {'d3'} {'d4'}];

   if strcmp(scaleby,'whole')
        pool = [segments.p4.scalars;segments.p3.scalars;segments.p2.scalars;segments.p1.scalars;segments.m1.scalars;...
        segments.m2.scalars;segments.d1.scalars;segments.d2.scalars;segments.d3.scalars;segments.d4.scalars;];

        cmin = min(pool(:));
        cmax = max(pool(:));
    end


    for ii = 1:length(regs)
    
        if strcmp(scaleby,'segment')
            cmin = min(segments.(regs{ii}).scalars(:));
            cmax = max(segments.(regs{ii}).scalars(:));
        end 
        
        rgb = vals2colormap(segments.(regs{ii}).scalars, 'redblue', [cmin cmax]);
        
        pc = pointCloud([segments.(regs{ii}).points(:,1) segments.(regs{ii}).points(:,2) segments.(regs{ii}).points(:,3)]);

        pc.A.r = rgb(:,1);
        pc.A.g = rgb(:,2);
        pc.A.b = rgb(:,3);

        pc.plot('Color','A.rgb');

    end

end