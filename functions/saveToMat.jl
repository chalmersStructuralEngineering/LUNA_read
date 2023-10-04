using MAT

function saveToMAT(data, folder)

    # Convert your struct to a dict of arrays
    dict_data = Dict(
        "time_ch1" => data.ch1,
        "ch1" => data.ch2,
        "time_ch2" => data.ch3,
        "ch2" => data.ch4,
    )

    # Write the dict to a .mat file
    matwrite(folder, dict_data)

end