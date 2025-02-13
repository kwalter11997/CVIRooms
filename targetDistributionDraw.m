
figure()
set(gca, 'YDir','reverse')
for i = 1:22
    hold on
    plot(polyshape(roisConVR.([sprintf('room%d', i)])))
end

ylim([50,500])