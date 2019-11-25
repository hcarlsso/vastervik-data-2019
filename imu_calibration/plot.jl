# plot_trace(trace, 1, params[:theta].acc_pos.r[:,1], "Axis array non synced")

plot_results_position(trace_r[:r], 1, r0[:,1])

# Plot angular velocity

y_gyro_wo_bias = data_for_opt[:y_dyn][range(9 + 1, length = 9),:] .- bias_gyro

figure(2);
clf();
directions = "xyz"
for m = 1:3
    subplot(3,1,m)
    for k = 1:3
        plot(data_for_opt[:time][3*(k-1) + m, : ],
             y_gyro_wo_bias[3*(k-1) + m , : ] * 180/pi, label = "$k")

    end
    plot(data_for_opt[:time][1, : ], params_r[:eta].w[m,:] * 180/pi, label = "est")
    grid(true)
    legend()
    title("gyro $(directions[m])")
    xlabel("time [s]")
    ylabel("w [deg/s]")
end


figure(3)
clf()

for k = 1:3
    inds = range( 3*(k-1) + 1, length = 3)
    w_k = norm_each_t(y_gyro_wo_bias[inds,:])
    plot(data_for_opt[:time][3*(k-1) + 1, :], w_k*180/pi, label = "$k")

end

# plot(data_for_opt[:time][1, : ], norm_each_t(params_r[:eta].w) * 180/pi, label = "est")

grid(true)
legend()
