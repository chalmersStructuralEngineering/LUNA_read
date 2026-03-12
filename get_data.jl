using Dates
using Sockets
using JSON3
using Statistics
using FillOutliers
# using PyCall

# @pyimport scipy.stats.mstats as mstats

function get_data(ts, j_map)  # ts: Number of calls per measurement to get the mean value

    data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)

    fail = 0  # variable to check the status of the connection to Luna
    att = 0  # control num attemptjulia --project=. main.jls to establish connection with Luna

    cond = true  # condition to keep the loop running

    while cond
        if fail == 0
            println("Reading iteration started: ", Dates.now())
        end
        try
            global t = Sockets.connect("127.0.0.1", 50000)
            println("Established connection with Luna, reading data")
            att = 0
            cond = false
        catch e
            att += 1
            println("Not possibjulia --project=. main.jlle to establish connection, re-trying. Attempt num.: ", att)
            t = nothing
            fail = 1
            continue
        end
        while length(readline(t)) == 0
            sleep(0.1)
        end
    end

    counter = 0

    while counter < ts
        str = String(readline(t))
        if str[1] != '{'
            str = str[6:end]
        end
        dec_data = JSON3.read(str)
        # Skip frames that are missing required keys (e.g. header/status messages)
        if !haskey(dec_data, "message type") || !haskey(dec_data, "data") || !haskey(dec_data, "channel")
            continue
        end
        # Mapping between JSON keys and field names of MyStruct
        data_values = Float64.(replace(dec_data["data"], nothing => NaN))
        new_data = reshape(data_values, 1, :)

        if dec_data["message type"] == "measurement" && !isempty(dec_data["data"])
            println(counter += 1)
            old_values = getfield(data, j_map[dec_data["channel"]])
            new_values = isempty(old_values) ? new_data : vcat(old_values, new_data)
            setfield!(data, j_map[dec_data["channel"]], new_values)
        end

    end

    println("Reading successful")
    close(t)
    println("Closed connection with Luna")

    for i in 1:8
        setfield!(data, j_map[i], filter_extreme_values(getfield(data, j_map[i])))
    end

    curr_time = Dates.now()
    return data, curr_time
end


function filter_extreme_values(data_in)
    # Return empty matrix unchanged if no data was collected for this channel
    if isempty(data_in)
        return data_in
    end
    # Here we use Python's scipy library for winsorization as a rough approximation for MATLAB's filloutliers function
    result = filloutliers(data_in, "move_mean", 11)
    # filloutliers can return nothing if it cannot process the data
    if isnothing(result)
        return mean(data_in, dims=1)
    end
    data_out = mean(result, dims=1)  # Similar to 'mean' function in MATLAB
    return data_out
end