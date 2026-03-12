using Dates
using MAT
using JLD2

include("get_data.jl")
include("uploadFileToSCP.jl")  # now contains uploadFileToSCP
include("uploadToPostgres.jl") # PostgreSQL upload

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
remote_dir = "/Natxo/"
j_map = Dict(i => Symbol("ch", i) for i in 1:8)
ts = 60  # Number of readings per measurement point

function make_filename(n)
    if n < 10
        return "PRC_numfile_00" * string(n) * ".jld2"
    elseif n < 100
        return "PRC_numfile_0" * string(n) * ".jld2"
    else
        return "PRC_numfile_" * string(n) * ".jld2"
    end
end

# Find the latest existing file number
listing = readdir(data_dir)
n_max = -1
for file in listing
    try
        num_file = parse(Int, file[end-7:end-5])
        global n_max = max(n_max, num_file)
    catch e
    end
end

# Load existing data, or start a new file if none exist or the last one exceeds 50 MB
if n_max == -1 || filesize(data_dir * make_filename(n_max)) > 50_000_000
    n = n_max + 1  # n_max == -1 → first file (0); too large → roll over
    raw_data = MyStruct([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
    curr_time = []
else
    n = n_max
    @load data_dir * make_filename(n) raw_data curr_time
end

println("Writing to file number: ", n)

# Read new data and append
data, timeF = get_data(ts, j_map)
for i in 1:8
    old_values = getfield(raw_data, j_map[i])
    new_values = getfield(data, j_map[i])
    new_data = isempty(old_values) ? new_values : vcat(old_values, new_values)
    setfield!(raw_data, j_map[i], new_data)
end
curr_time = vcat(curr_time, timeF)

filename = make_filename(n)
@save data_dir * filename raw_data curr_time

# Upload the new acquisition to PostgreSQL
uploadToPostgres(data, timeF, n, j_map)

username = ENV["SSH_USERNAME"]
hostname = ENV["SSH_HOSTNAME"]
key_path = get(ENV, "SSH_KEY_PATH", nothing)  # optional: path to private key
uploadFileToSCP(data_dir * filename, remote_dir * filename, username, hostname; key_path=key_path)

println("Reading finished: ", Dates.now())

#ssh-keygen -t ed25519 -f ~/.ssh/luna_key
#ssh-copy-id -i ~/.ssh/luna_key.pub user@your-rhel-host