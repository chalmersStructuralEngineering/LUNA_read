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
sMat = true  # save to .mat file
sJLD2 = true  # save to .jld2 file

data_dir_FTC = "./test_data/FTC/"
ftp_dir_FTC = "/Fatigue_test/Beam1/"

raw_data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
FTC_data = MyStruct4([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)

j_map = Dict(i => Symbol("ch", i) for i in 1:8)

ts = 64  # Number of readings per measurement point to divide between number of active channels
int = 3600  # Time interval between readings in seconds
j = 1

curr_time = []

listing = readdir(data_dir_FTC)

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

    tic = Dates.now()  # equivalent to MATLAB's tic
    try
        global ts, j_map, data, timeF
        data, timeF = get_data(ts, j_map)
    catch e
        println("Error in get_data")
        println(e)
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"],
            ["<fignasi@chalmers.se>", "<david.dackman@chalmers.se>", "<berrocal@chalmers.se>"],
            "Failed to read data from Luna, Error in get_data")
        exit(1)
    end

    for i in 1:8
        old_values = getfield(raw_data, j_map[i])
        new_values = getfield(data, j_map[i])
        new_data = isempty(old_values) ? new_values : vcat(old_values, new_values)
        setfield!(raw_data, j_map[i], new_data)
    end

    curr_time =
        vcat(curr_time, timeF)
    if n < 10
        filename_FTC = "FTC_numfile_00" * string(n)
    elseif n < 100
        filename_FTC = "FTC_numfile_0" * string(n)
    else
        filename_FTC = "FTC_numfile_" * string(n)
    end

    #### Divide the data series, save files and upload to the corresponding folders
    # Divide data series in 2 parts corresponding to the 2 tests
    for i = 1:4
        setfield!(FTC_data, j_map[i], getfield(raw_data, j_map[i]))
    end

    if sJLD2 == true
        println("Saving data to .jld2 file")
        # Save data in Julia format

        @save data_dir_FTC * filename_FTC * ".jld2" FTC_data curr_time
        println("Data saved to .jld2 file")

    end

    if sMat == true
        println("Saving data to MATLAB file")
        # Save data in MATLAB format

        saveToMAT(FTC_data, curr_time, data_dir_FTC * filename_FTC * "_.mat")

        println("Data saved to MATLAB file")
    end

    if uFTP == true
        # Upload to FTP (Box) server
        println("Uploading data to FTP server")
        files = Dict("FTC_data" => [data_dir_FTC * filename_FTC * ".jld2"; ftp_dir_FTC * filename_FTC * ".jld2"],
            "FTC_data_mat" => [data_dir_FTC * filename_FTC * "_.mat"; ftp_dir_FTC * filename_FTC * "_.mat"])
        uploadFileToFTP(files, ENV["FTP_USERNAME_box"], ENV["FTP_PASSWORD_box"], ENV["FTP_HOSTNAME_box"],
            ["<fignasi@chalmers.se>", "<mozhdeh.amani@chalmers.se>", "<berrocal@chalmers.se>"])
    end
    println("Reading iteration finished: ", Dates.now())

    # Send control email every 24 iterations (4 hours)
    if mod(j, 24) == 0
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"],
            ["<fignasi@chalmers.se>", "<mozhdeh.amani@chalmers.se>", "<berrocal@chalmers.se>"], "Reading control every 4h!")
    end
    j += 1

    # 50 MB, splitting of files if they are too big
    if (filesize(data_dir_FTC * filename_FTC * ".jld2") > 50000000) || (filesize(data_dir_FTC * filename_FTC * ".jld2") > 50000000)
        raw_data = MyStruct8([Matrix{Float64}(undef, 0, 0) for _ in 1:8]...)
        curr_time = []
        j = 1
        n += 1
    end

    toc = Dates.now()
    elapsed = Dates.value(toc - tic) / 1000 # elapsed time in seconds
    println("Elapsed time: ", elapsed)
    println("########################################")

    # we wait until next iteration starts (int seconds)
    time_left = int - elapsed
    if time_left > 0
        sleep(time_left)
    end

end