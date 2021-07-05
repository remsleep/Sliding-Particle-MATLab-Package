numTraj = size(TRAJECTORY,2);
badTrajs = [];
index = 1;
for traj = 1:numTraj
    frames = TRAJECTORY(traj).FRAME;
    badIndices = find(diff(frames) >= 5);
    if(~isempty(badIndices))
        badTrajs(index) = traj;
        index = index + 1;
    end
end