using Dates
using Sockets
using JSON3
using Statistics
using FillOutliers

function get_data(ts, j_map)  # ts: Number of calls per measurement to get the mean value

    data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
    str = matread("matlab.mat")
    counter = 0
    i = 0
    while counter < ts
        dec_data = JSON3.read(str["str"])
        # Mapping between JSON keys and field names of MyStruct
        data_values = replace(dec_data["data"], nothing => NaN)
        new_data = reshape(data_values, 1, :)

        if dec_data["message type"] == "measurement" && !isempty(dec_data["data"])
            for i = 1:8
                # println(counter += 1)
                old_values = getfield(data, j_map[i])
                new_values = isempty(old_values) ? new_data : vcat(old_values, new_data)
                setfield!(data, j_map[i], new_values)
            end
        end

    end

    println("Reading successful")
    println("Closed connection with Luna")

    for i = 1:8
        setfield!(data, j_map[i], filter_extreme_values(getfield(data, j_map[i])))
    end

    curr_time = Dates.now()
    return data, curr_time

end


function filter_extreme_values(data_in)
    
    data_in = filloutliers(data_in, "moving_mean", 11)
    data_out = mean(data_in, dims=1)  # Similar to 'mean' function in MATLAB
    return data_out

end