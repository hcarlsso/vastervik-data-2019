% Dynamic measurements 

clear all; close all;
addpath ../lib_matlab/
% rosbag = rosbag('imu_data.bag');
rosbag = rosbag('2019-09-16-11-33-16.bag');

data = cell(3,1);
for k = 1:3
    bSe1 = select(rosbag, 'Topic', sprintf('/camera%d/imu', k));
    msgStructs = readMessages(bSe1, 'DataFormat','struct');
    
    data{k}.time = cellfun(@(m) get_time(m), msgStructs);
    data{k}.time = data{k}.time - data{k}.time(1);
    data{k}.gyro = get_angular_velocity(msgStructs);
    data{k}.acc = get_acceleration(msgStructs);
end


%% Check that time is the same on all imus

markers = 'xos';

figure(1); clf; hold on
for k = 1:3
    plot(data{k}.time, markers(k))
end

grid on
% Not the same time


%% Filter out duplicates
% Find points where to  calculate gyrod
% Assume that al least two sample in time are adjecent

data_red = cell(3,1);

colors = 'rgb';

figure(2); clf; 
figure(3); clf; 
axes = cell(3,1);

% Need to center the line
t_n_range = linspace(- 0.02, 0.02, 3);
for k = 1:3
    mask = [0; diff(data{k}.time)] > 0.0;
    mask_first_point = [0; diff(data{k}.time)] > 0.05;
    mask_second_point = [false; mask_first_point(1:end-1)];

    data_red{k}.gyrod = (data{k}.gyro(:, mask_second_point) - data{k}.gyro(:, mask_first_point)) ./ ( data{k}.time(mask_second_point) - data{k}.time(mask_first_point))'  ;
    
        
    mask_final = mask_first_point;
    data_red{k}.time = data{k}.time(mask_final);
    data_red{k}.gyro = data{k}.gyro(:, mask_final);
    data_red{k}.acc = data{k}.acc(:,mask_final);
    
    % Remove nan from differentiation 
    mask_nan = ~isnan(data_red{k}.gyrod);
    mask_nan = mask_nan(1,:);
    
    data_red{k}.time = data_red{k}.time(mask_nan);
    data_red{k}.gyro = data_red{k}.gyro(:, mask_nan);
    data_red{k}.gyrod = data_red{k}.gyrod(:, mask_nan);
    data_red{k}.acc = data_red{k}.acc(:, mask_nan);
    
    figure(2); 
    for m = 1:3
        axes{m} = subplot(3,1,m); 
        hold on;
        plot(data{k}.time, data{k}.gyro(m, :), ['--' colors(k)])
        plot(data_red{k}.time, data_red{k}.gyro(m, :), ['x' colors(k)])
        plot(data{k}.time(mask_second_point), data{k}.gyro(m, mask_second_point), ['o' colors(k)])
        
        for n = 1:length(data_red{k}.time)
            t_n = data_red{k}.time(n);
            if ~isnan(data_red{k}.gyrod(m,n))
                gyrod_range = polyval([data_red{k}.gyrod(m,n) data_red{k}.gyro(m,n)] , t_n_range);
                % gyrod_range = polyval([data_red{k}.gyro(m,n)], t_n_range);
                plot(t_n_range + t_n, gyrod_range, ['-s' colors(k)])
            end

        end
        grid on
        ylim([-3 3])
    end
    
    % Acc
    figure(3); 
    for m = 1:3
        axes{m} = subplot(3,1,m); 
        hold on;
        plot(data{k}.time, data{k}.acc(m, :), ['--' colors(k)])
        plot(data_red{k}.time, data_red{k}.acc(m, :), ['x' colors(k)])

        grid on    
    end
end
linkaxes([axes{:}])


%% Rotate to right handed 


j = 0;

directions = 'xyz';

% rotations_matrix.acc = diag([1, 1, -1]);
% rotations_matrix.gyro = diag([-1, -1, 1])*180/pi;

rotations_matrix.acc = diag([1, 1, -1]);
rotations_matrix.gyro = diag([-1, -1, 1])*180/pi;
rotations_matrix.gyrod = diag([-1, -1, 1])*180/pi;

data_rot = cell(3,1);

for sense_type  = {'acc', 'gyro', 'gyrod'}
    % sense_type{:}
    figure(4 + j); clf
    axes = cell(3,1);
    for k = 1:3
        rot_m = getfield(rotations_matrix, sense_type{:});
        data_type = rot_m*getfield(data_red{k}, sense_type{:});
        imu_time = data_red{k}.time - data_red{k}.time(1);
        
        data_rot{k} = setfield(data_rot{k}, sense_type{:}, data_type);
        data_rot{k}.time = imu_time;
        for i = 1:3
            axes{i} = subplot(3,1, i);
            hold on;
            plot(imu_time , data_type(i,:), 'x')

            title([sense_type{:} ' ' directions(i)])
            grid on
            xlabel('time [s]')
        end
        
    end
    linkaxes([axes{:}],'x')
    j = j +1;
end



%% save data

save('dynamic_measurements.mat', 'data_rot')
