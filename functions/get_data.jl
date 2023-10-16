using Dates
using Sockets
using JSON3
using Statistics
using FillOutliers
using TimesDates

function get_data(ts, j_map)  # ts: Number of calls per measurement to get the mean value


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


    try
        global j_map
        counter = 0
        data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        time_data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        while counter < ts
            global j_map
            str = String(readline(t))
            if str[1] != '{'
                str = str[6:end]
            end
            dec_data = JSON3.read(str)
            # Mapping between JSON keys and field names of MyStruct
            if dec_data["message type"] == "measurement" && !isempty(dec_data["data"])
                dt = [(dec_data.year), (dec_data.month), (dec_data.day),
                    (dec_data.hours), (dec_data.minutes), (dec_data.seconds),
                    (dec_data.milliseconds), (dec_data.microseconds)]
                data_values = replace(dec_data["data"], nothing => NaN)
                if dec_data.channel == 3
                    data_values = data_values[673:end, 1]  # remove first 672 values as they are outside the measurement range
                elseif dec_data.channel == 6
                    data_values = data_values[1346:end, 1]  # remove first 1345 values as they are outside the measurement range
                end
                new_data = convert(Matrix{Float64}, reshape(data_values, 1, :))
                new_time = convert(Matrix{Float64}, reshape(dt, 1, :))
                println(counter += 1)
                old_values = getfield(data, j_map[dec_data["channel"]])
                old_values_t = getfield(time_data, j_map[dec_data["channel"]])
                new_values = isempty(old_values) ? new_data : vcat(old_values, new_data)
                new_values_t = isempty(old_values_t) ? new_time : vcat(old_values_t, new_time)
                setfield!(data, j_map[dec_data["channel"]], new_values)
                setfield!(time_data, j_map[dec_data["channel"]], new_values_t)
            end
        end
        println("Reading successful ", counter, " iterations")
        close(t)
        println("Closed connection with Luna")


        return data, time_data
    catch e
        println("Error in reading data")
        println(e)
        close(t)
    end

end