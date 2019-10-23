figure(1); clf; hold on
axes = cell(3,1);
for i = 1:3
    axes{i} = subplot(3,1,i);
    plot(time_offset(mask), w(i,mask), 'x-')
    grid on
end
linkaxes([axes{:}])

%% 
mask = [0; diff(time)] > 0.0;
seq = 1:length(time);

figure(3); clf; 
ax{1} = subplot(2,1,1);
hold on
for i = 1:3
    plot(w(i,:), 'x-')
    plot(seq(mask), w(i,mask), 'ko')
end
grid on

ax{2} = subplot(2,1,2);
time_offset = time - time(1);
plot(time_offset, 'x')
hold on;
plot(seq(mask), time_offset(mask), 'ok')
grid on
linkaxes([ax{:}], 'x')

%% 
figure(2); clf;

subplot(3,1,1)
plot(time_sec - time_sec(1))
hold on 
time = cellfun(@(m) get_time(m), msgStructs);
plot(time - time(1),'x-')
subplot(3,1,2)
plot(double(time_nsec)/1e9, '-x')

subplot(3,1,3)
plot(diff(time))
