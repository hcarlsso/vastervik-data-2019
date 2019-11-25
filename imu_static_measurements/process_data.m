%% Read bag data static measurements 

clear all; close all;

rosbag = rosbag('data/2019-09-15-19-45-17.bag');

data = cell(3,1);
for k = 1:3
    bSe1 = select(rosbag, 'Topic', sprintf('/camera%d/imu', k));
    msgStructs = readMessages(bSe1, 'DataFormat','struct');
    
    data{k}.time = cellfun(@(m) get_time(m), msgStructs);
    data{k}.gyro = get_angular_velocity(msgStructs);
    data{k}.acc = get_acceleration(msgStructs);
end

%% Check that time is the same on all imus

markers = 'xos';

figure(1); clf; hold on
for k = 1:3
    plot(data{k}.time, markers(k))
end

% Not the same time


%% Filter out duplicates

data_red = cell(3,1);

for k = 1:3
    mask = [0; diff(data{k}.time)] > 0.0;

    data_red{k}.time = data{k}.time(mask);
    data_red{k}.time = data_red{k}.time - data_red{k}.time(1);
    data_red{k}.gyro = data{k}.gyro(:, mask);
    data_red{k}.acc = data{k}.acc(:,mask);
end

figure(2); clf
j = 0;
axes = cell(6,1);
directions = 'xyz';
for sense_type  = {'acc', 'gyro'}
    sense_type
    for k = 1:3
        subplot(6,1, 3*j + k)
        data_type = getfield(data_red{k}, sense_type{:});
        imu_time = data_red{k}.time - data_red{k}.time(1);
        for i = 1:3
            axes{3*j+i} = subplot(6,1, 3*j + i);
            hold on;
            plot(imu_time , data_type(i,:))
            title([sense_type{:} ' ' directions(i)])
            grid on
        end
        
    end
    j = j +1;
end

linkaxes([axes{:}],'x')

%% Rotate to right handed 

figure(3); clf
j = 0;
axes = cell(6,1);
directions = 'xyz';

rotations_matrix.acc = diag([1, 1, -1]);
rotations_matrix.gyro = diag([-1, -1, 1])*180/pi;

data_rot = cell(3,1);

for sense_type  = {'acc', 'gyro'}
    % sense_type{:}
    for k = 1:3
        subplot(6,1, 3*j + k)
        rot_m = getfield(rotations_matrix, sense_type{:});
        data_type = rot_m*getfield(data_red{k}, sense_type{:});
        imu_time = data_red{k}.time - data_red{k}.time(1);
        
        data_rot{k} = setfield(data_rot{k}, sense_type{:}, data_type);
        data_rot{k}.time = imu_time;
        for i = 1:3
            axes{3*j+i} = subplot(6,1, 3*j + i);
            hold on;
            plot(imu_time , data_type(i,:))
            title([sense_type{:} ' ' directions(i)])
            grid on
            xlabel('time [s]')
        end
        
    end
    j = j +1;
end

linkaxes([axes{:}],'x')
%%

if false
    points = [cursor_info.Position];
    points = sort(points(1:2:end));
    save('static_points.mat', 'points');
else
    load('static_points.mat', 'points');
end

data_static = sort_static_measurements(data_rot, points);


%% plot static measurements 

figure(4); clf;
for n = 1:length(data_static)

    for m = 1:3
        subplot(3,1,m)
        hold on 
        for k = 1:3
            
            plot(data_static{n}.time{k}, ...
                data_static{n}.acc{k}(m,:))
            
            
        end
    end
    
end

save('data_static.mat', 'data_static')

% 
% 
% % 
% mask = [0; diff(time)] > 0.0;
% seq = 1:length(time);
% 
% figure(3); clf; 
% ax{1} = subplot(2,1,1);
% hold on
% for i = 1:3
%     plot(w(i,:), 'x-')
%     plot(seq(mask), w(i,mask), 'ko')
% end
% grid on
% 
% ax{2} = subplot(2,1,2);
% time_offset = time - time(1);
% plot(time_offset, 'x')
% hold on;
% plot(seq(mask), time_offset(mask), 'ok')
% grid on
% linkaxes([ax{:}], 'x')
% 
% % 
% figure(2); clf;
% 
% subplot(3,1,1)
% plot(time_sec - time_sec(1))
% hold on 
% time = cellfun(@(m) get_time(m), msgStructs);
% plot(time - time(1),'x-')
% subplot(3,1,2)
% plot(double(time_nsec)/1e9, '-x')
% 
% subplot(3,1,3)
% plot(diff(time))