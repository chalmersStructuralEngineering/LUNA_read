using Dates
using MAT
using JLD2
using TickTock
using Revise

include("get_data.jl")
include("uploadFileToFTP2.jl")

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
data_dir = "./test_data/"
ftp_dir = "/Natxo/"

raw_data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
j_map = Dict(i => Symbol("ch", i) for i in 1:8)

ts = 60  # Number of readings per measurement point
int = 600  # Time interval between readings
j = 1

curr_time = []

listing = readdir(data_dir)
n = 0

for file in listing
    num_file = 0
    try
        num_file = parse(Int, file[end-7:end-5])
    catch e
    end
    global n = max(n, num_file + 1)
end

# Now you can access the value of n
println(n)


# Starting loop for reading and storing data every XXX seconds (int)
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
        filename = "PRC_numfile_00" * string(n) * ".jld2"
    elseif n < 100
        filename = "PRC_numfile_0" * string(n) * ".jld2"
    else
        filename = "PRC_numfile_" * string(n) * ".jld2"
    end

    j += 1

    @save data_dir * filename raw_data curr_time

    uploadFileToFTP2(data_dir * filename, ftp_dir * filename)

    println("Reading iteration finished: ", Dates.now())

    if filesize(data_dir * filename) > 50000000
        raw_data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        curr_time = []
        j = 1
        n += 1
    end
    toc = now()  # equivalent to MATLAB's toc
    elapsed = Dates.value(toc - tic) / 1000000  # elapsed time in milliseconds
    println("Elapsed time: ", elapsed)
    println("########################################")
    time_left = int - elapsed

    if time_left > 0
        sleep(time_left)
    end
end