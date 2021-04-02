function [] = FUNC_HistogramVelTotal(allVelInfo)
%FUNC_HITSOGRAMVELTOTAL Simple function to plot histogram distribution of
%velocities in allVelInfo array. 

[N, edges] = histcounts(allVelInfo(1,:));
hold off
plot(edges(2:end),N);
hold on

maxInd = find(N == max(N));
scatter(edges(maxInd+1),N(maxInd),'filled');
title('Binned sliding velocities between channels')
ylabel('Count')
xlabel('Relative Sliding Velocity (um/sec)')
set(gca,'FontSize',15)
end

