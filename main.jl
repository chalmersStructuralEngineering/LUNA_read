using Dates
using MAT
using JLD2

# get_data2.jl to run locally wothout any socket connection
include("get_data_2.jl")
include("uploadFileToFTP.jl")
include("saveToMat.jl")

mutable struct MyStruct
    ch1::Matrix{Float64}
    ch2::Matrix{Float64}
    ch3::Matrix{Float64}
    ch4::Matrix{Float64}
    ch5::Matrix{Float64}
    ch6::Matrix{Float64}
    ch7::Matrix{Float64}
    ch8::Matrix{Float64}
end

data_dir = "./test_data/Davids_test/Series_2/"
ftp_dir = "/Natxo/"#"/Davids_test/Series_2/"

raw_data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)

j_map = Dict(i => Symbol("ch", i) for i in 1:8)

ts = 60  # Number of readings per measurement point to divide between number of active channels
int = 5  # Time interval between readings in seconds
j = 1

curr_time = []

listing = readdir(data_dir)

# check if the directory is empty
if isempty(listing)
    println("Directory is empty")
    n = 1
else
    n = 0
    for file in listing
        try
            num_file = parse(Int, file[end-7:end-5])
            global n = max(n, num_file + 1)
        catch e
            println("DEBUG: could not parse file ", file)
        end
    end
end

# Now you can access the value of n
println(n)


# Starting loop for reading and storing data every (int) seconds
cond = true
while cond # while true
    
    global raw_data, curr_time, j, n
    println("########################################")
    println("Iteration num.: ", j)

    tic = now()  # equivalent to MATLAB's tic

    data, timeF = get_data(ts, j_map)
    for i in 1:8
        old_values = getfield(raw_data, j_map[i])
        new_values = getfield(data, j_map[i])
        new_data = isempty(old_values) ? new_values : vcat(old_values, new_values)
        setfield!(raw_data, j_map[i], new_data)
    end

    curr_time = vcat(curr_time, timeF)

    if n < 10
        filename = "DTs2_numfile_00" * string(n)
    elseif n < 100
        filename = "DTs2_numfile_0" * string(n)
    else
        filename = "DTs2_numfile_" * string(n)
    end

    j += 1

    # Save data in Julia format
    @save data_dir * filename * ".jld2" raw_data curr_time

    # Save data in MATLAB format
    saveToMAT(raw_data, data_dir * filename * "_.mat")

    # Upload to FTP (Box) server
    username = ENV["FTP_USERNAME"]
    password = ENV["FTP_PASSWORD"]
    hostname = ENV["FTP_HOSTNAME"]

    uploadFileToFTP(data_dir * filename * ".jld2", ftp_dir * filename * ".jld2", username, password, hostname)
    uploadFileToFTP(data_dir * filename * ".mat", ftp_dir * filename * ".mat", username, password, hostname)

    println("Reading iteration finished: ", Dates.now())

    # 50 MB, splitting of files if they are too big
    if filesize(data_dir * filename * ".jld2") > 50000000
        raw_data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        curr_time = []
        j = 1
        n += 1
    end
    toc = now()  # equivalent to MATLAB's toc
    elapsed = Dates.value(toc - tic) / 1000000  # elapsed time in seconds
    println("Elapsed time: ", elapsed)
    println("########################################")

    # we wait until next iteration starts (int seconds)
    time_left = int - elapsed
    if time_left > 0
        sleep(time_left)
    end

end