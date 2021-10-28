function reduced_segments = pc_reduce(inp,NUMBER_POINTS,dsply)

regs  = [{'p4'} {'p3'} {'p2'} {'p1'} {'m1'} {'m2'} {'d1'} {'d2'} {'d3'} {'d4'}];

segments = load(inp);

for ii = 1:length(regs)

    reduced_segments.(regs{ii}) = interval_subsample(segments.(regs{ii}), NUMBER_POINTS,dsply);

end

end


function out = interval_subsample(inp, target,dsply)

    inlen = length(inp.points);
    initFactor = inlen/target;

    pc = pointCloud([inp.points(:,1) inp.points(:,2) inp.points(:,3)], 'Label', inputname(1));
    pc.select('IntervalSampling',initFactor);

    initOutcome = length(pc.act(pc.act==1));

    if initOutcome~=target

        if initOutcome > target
            
            idx = find(pc.act==1);
            rmv = idx(randperm(numel(idx),initOutcome-target));
            pc.act(rmv) = 0;

        elseif initOutcome < target
            
            idx = find(pc.act==0);
            inc = idx(randperm(numel(idx),target-initOutcome));
            pc.act(inc) = 1;

        end

    end
    

    

    out = struct();
    out.scalars = inp.scalars(pc.act);
    out.points  = inp.points(pc.act,:);
    
    if dsply
        rgb = vals2colormap(out.scalars, 'jet', [min(out.scalars) max(out.scalars)]);

        pc.A.r = zeros(inlen,1);
        pc.A.g = zeros(inlen,1);
        pc.A.b = zeros(inlen,1);

        pc.A.r(pc.act) = rgb(:,1);
        pc.A.g(pc.act) = rgb(:,2);
        pc.A.b(pc.act) = rgb(:,3);

        pc.plot('Color','A.rgb');
    end
end