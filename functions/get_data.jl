using Dates
using Sockets
using JSON3
using Statistics
using FillOutliers

function get_data(ts, j_map)  # ts: Number of calls per measurement to get the mean value

    data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)

    fail = 0  # variable to check the status of the connection to Luna
    att = 0  # control num attempts to establish connection with Luna

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
            println("Not possible to establish connection, re-trying. Attempt num.: ", att)
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
        # Mapping between JSON keys and field names of MyStruct
        data_values = replace(dec_data["data"], nothing => NaN)
        new_data = convert(Matrix{Float64}, reshape(data_values, 1, :))

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

    curr_time = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
    return data, curr_time

end


function filter_extreme_values(data_in)

    #data_in = filloutliers(data_in, "moving mean", 11)
    data_out = mean(data_in, dims=1)  # Similar to 'mean' function in MATLAB
    return data_out

end