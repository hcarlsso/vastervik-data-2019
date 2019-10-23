function data_static = sort_static_measurements(data, points)

    assert(mod(length(points),2) == 0)
    
    points = sort(points);
    points_lb = points(1:2:end);
    points_ub = points(2:2:end);
    
    % Statics 

    % Points are from cursor in time [s]
    data_static = cell(length(points)/2,1);
    for i = 1:length(points_ub)
        % Iterate IMU
        acc = cell(3,1);
        gyro = cell(3,1);
        time = cell(3,1);
        for k = 1:3
            mask = points_lb(i) < data{k}.time &  data{k}.time < points_ub(i);

            
            acc{k} = data{k}.acc(:, mask);
            gyro{k} = data{k}.gyro(:, mask);
            time{k} = data{k}.time(mask);
        end
        data_static{i}.acc = acc;
        data_static{i}.gyro = gyro;
        data_static{i}.time = time;
    end
    

end