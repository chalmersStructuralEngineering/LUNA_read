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
mutable struct MyStruct1
    data::Matrix{Float64}
end

# get_data2.jl to run locally without any socket connection
include("./functions/get_data.jl")
include("./functions/uploadFileToFTP.jl")
include("./functions/saveToMat.jl")
include("./functions/sendEmail.jl")
include("./functions/get_loads.jl")

data_dir_DTs2 = "./test_data/Davids_test/Series_2/"
data_dir_PRC = "./test_data/PRC/"
ftp_dir_DTs2 = "/Davids_test/Series_2/"
ftp_dir_PRC = "/PostDOFS/Series_2/"#"/Davids_test/Series_2/"
n = 1
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

for i = 1:4
    username = ENV["SFTP_USERNAME_lc"]
    password = ENV["SFTP_PASSWORD_lc"]
    hostname = ENV["SFTP_HOSTNAME_lc"]
    remote_path = "/data/stream.json"
    loads = downloadFileFromSFTP(remote_path, username, password, hostname)
    if i == 1
        println(i)
        global load_data = loads["data"][:]'
    else
        println(i)
        global load_data = [load_data; loads["data"][:]']
    end
    if i == 4
        global load_data = loads["data"][:]'
    end
end
