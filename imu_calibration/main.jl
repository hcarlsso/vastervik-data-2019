function get_static_data()

    file = matopen("../imu_static_measurements/data_static.mat")
    data = read(file, "data_static")
    close(file)
    return data
end
"""
    mean and variance for each direction
"""
function estimate_mean_and_variance_static_array_axis(data)
    mean_and_var = map(data) do data_dir
        map(data_dir) do data_imu
            imu_mean = mean(data_imu, dims = 2)
            imu_var = var(data_imu; dims = 2)
            n_samples = size(data_imu, 2)

            (imu_mean, imu_var, n_samples)
        end
    end
    sequence_mean = hcat(
        [vcat([x[1] for x in d_dir]...) for d_dir in mean_and_var]...
    )
    sequence_var = map(1:length(mean_and_var[1])) do k
        var_ests = [d_dir[k][2] for d_dir in mean_and_var]
        n_samples = [d_dir[k][3] for d_dir in mean_and_var]

        total_var_est = estimate_sample_variance_from_multiple_var_ests(
            var_ests, n_samples
        )
        total_var_est[:]
    end


    return sequence_mean, vcat(sequence_var...)
end
"""
    (approximate) minimum variance unbiased linear estimator of the population variance

    https://stats.stackexchange.com/questions/243922/how-to-estimate-population-variance-from-multiple-samples
"""
function estimate_sample_variance_from_multiple_var_ests(var_ests, n_samples)
    sum([(n-1)*v for (v, n) in zip(var_ests, n_samples)])./(sum(n_samples) - length(n_samples))
end
function get_theta_0(Na)
    ScaleBiasMatrix(cat([eye(3) for k = 1:Na]...; dims = 3), zeros(3,Na))
end
function static_calibration(y, variance, iter_bcd)

    Na = 3

    m = MeasurementSequence(y, diagm(0=> 1 ./variance))
    mimu = Acc(Na)
    error_mse = zeros(iter_bcd)
    p = Progress(iter_bcd)
    function store_func_bcd(theta, eta, n::Integer)
        error_mse[n] = cost(m, eta, theta, mimu)
        next!(p; showvalues = [(:cost, error_mse[n])])
    end

    opt_bisection = OptimizationSettings(1e-8, 100)
    opt_bcd =  BcdSettings(
        0.0,
        0.0,
        iter_bcd,
        true,
        store_func_bcd
    )



    theta, eta = ml_mimu_scale_bias_gravity(
        get_theta_0(Na), m, get_local_g_mag(),
        mimu, opt_bisection, opt_bcd
    )

    finish!(p)

    figure(1); clf()
    loglog(1:iter_bcd, error_mse)
    grid(true)
    return theta, eta
end
function save_data(filename, T,b)
    h5open(filename, "w") do file
        for n = 1:size(T,3)
            R, Q = RQ_factorize_preserve_sign(T[:,:,n])

            show_matrix("imu_$(n)", R, Q, T[:,:,n] )

            write(file, "imu_$(n)/R", R)
            write(file, "imu_$(n)/Q", Q)
            write(file, "imu_$(n)/b", b[:,n])
        end
    end
end
function main()
    data = get_static_data()
    # get_acc_data
    data = map( x-> x["acc"], data)
    data_1 = estimate_mean_and_variance_static_array_axis(data)

    theta, eta = static_calibration(data_1[1], data_1[2], 2000)

    show_matrix(
        "T", theta.T, "b", theta.b, "g", eta.g
    )

    save_data("rotation.h5", theta.T, theta.b)

end
