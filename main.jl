using Dates
using JLD2

mutable struct MyStruct8
    ch1::Matrix{Float64}
    ch2::Matrix{Float64}
    ch3::Matrix{Float64}
    ch4::Matrix{Float64}
    ch5::Matrix{Float64}
    ch6::Matrix{Float64}
    ch7::Matrix{Float64}
    ch8::Matrix{Float64}
end

mutable struct MyStruct4
    ch1::Matrix{Float64}
    ch2::Matrix{Float64}
    ch3::Matrix{Float64}
    ch4::Matrix{Float64}
end

# get_data2.jl to run locally without any socket connection
include("./functions/get_data.jl")
include("./functions/uploadFileToFTP.jl")
include("./functions/saveToMat.jl")
include("./functions/sendEmail.jl")


uFTP = true  # upload to FTP
data_dir_DTs2 = "./test_data/Davids_test/Series_2/"
data_dir_PRC = "./test_data/PRC/"
ftp_dir_DTs2 = "/Davids_test/Series_2/"
ftp_dir_PRC = "/PostDOFS/Series_2/"#"/Davids_test/Series_2/"

raw_data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
PRC_data = MyStruct4([Matrix{Float64}(undef, 0, 0) for _ in 1:4]...)
DTs2_data = MyStruct4([Matrix{Float64}(undef, 0, 0) for _ in 1:4]...)

j_map = Dict(i => Symbol("ch", i) for i in 1:8)

ts = 60  # Number of readings per measurement point to divide between number of active channels
int = 10  # Time interval between readings in seconds
j = 1

curr_time = []

listing = readdir(data_dir_PRC)

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

# Recipient of the email with the error message
rcpt = ["<fignasi@chalmers.se>", "<david.dackman@chalmers.se>", "<berrocal@chalmers.se>"]

# Starting loop for reading and storing data every (int) seconds
cond = true
while cond # while true
    global raw_data, curr_time, j, n, rcpt

    println("########################################")
    println("Iteration num.: ", j)

    tic = Dates.now()  # equivalent to MATLAB's tic
    try
        global ts, j_map, data, timeF
        data, timeF = get_data(ts, j_map)
    catch e
        println("Error in get_data")
        println(e)
        # sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], rcpt, "Failed to read data from Luna, Error in get_data")
        #exit(1)
    end
    for i in 1:8
        old_values = getfield(raw_data, j_map[i])
        new_values = getfield(data, j_map[i])
        new_data = isempty(old_values) ? new_values : vcat(old_values, new_values)
        setfield!(raw_data, j_map[i], new_data)
    end

    curr_time = vcat(curr_time, timeF)

    if n < 10
        filename_DTs2 = "DTs2_numfile_00" * string(n)
        filename_PRC = "PRC_numfile_00" * string(n)
    elseif n < 100
        filename_DTs2 = "DTs2_numfile_0" * string(n)
        filename_PRC = "PRC_numfile_0" * string(n)
    else
        filename_DTs2 = "DTs2_numfile_" * string(n)
        filename_PRC = "PRC_numfile_" * string(n)
    end

    j += 1

    println("Saving data loacally")
    #### Divide the data series, save files and upload to the corresponding folders
    # Divide data series in 2 parts corresponding to the 2 tests
    for i = 1:4
        setfield!(DTs2_data, j_map[i], getfield(raw_data, j_map[i]))
        setfield!(PRC_data, j_map[i], getfield(raw_data, j_map[i+4]))
    end

    # Save data in Julia format
    @save data_dir_DTs2 * filename_DTs2 * ".jld2" DTs2_data curr_time
    @save data_dir_PRC * filename_PRC * ".jld2" PRC_data curr_time

    # Save data in MATLAB format
    saveToMAT(DTs2_data, curr_time, data_dir_DTs2 * filename_DTs2 * "_.mat")
    saveToMAT(PRC_data, curr_time, data_dir_PRC * filename_PRC * "_.mat")
    if uFTP == true
        # Upload to FTP (Box) server
        println("Uploading data to FTP server")
        username = ENV["FTP_USERNAME_box"]
        password = ENV["FTP_PASSWORD_box"]
        hostname = ENV["FTP_HOSTNAME_box"]

        uploadFileToFTP(data_dir_DTs2 * filename_DTs2 * ".jld2", ftp_dir_DTs2 * filename_DTs2 * ".jld2", username, password, hostname, rcpt)
        uploadFileToFTP(data_dir_DTs2 * filename_DTs2 * "_.mat", ftp_dir_DTs2 * filename_DTs2 * ".mat", username, password, hostname, rcpt)

        uploadFileToFTP(data_dir_PRC * filename_PRC * ".jld2", ftp_dir_PRC * filename_PRC * ".jld2", username, password, hostname, rcpt)
        uploadFileToFTP(data_dir_PRC * filename_PRC * "_.mat", ftp_dir_PRC * filename_PRC * ".mat", username, password, hostname, rcpt)
    end
    println("Reading iteration finished: ", Dates.now())

    # Send control email every 24 iterations (4 hours)
    if mod(j, 24) == 0
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], rcpt, "Control reading every 4h!")
    end

    # 50 MB, splitting of files if they are too big
    if filesize(data_dir_PRC * filename_PRC * ".jld2") > 50000000
        raw_data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        curr_time = []
        j = 1
        n += 1
    end

    toc = Dates.now()  # equivalent to MATLAB's toc
    elapsed = Dates.value(toc - tic) / 1000 # elapsed time in seconds
    println("Elapsed time: ", elapsed)
    println("########################################")

    # we wait until next iteration starts (int seconds)
    time_left = int - elapsed
    if time_left > 0
        sleep(time_left)
    end

end