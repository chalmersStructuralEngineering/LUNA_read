using MAT

function saveToMAT(data, folder)

    # Convert your struct to a dict of arrays
    dict_data = Dict(
        "time_ch3" => data.ch1,
        "ch3" => data.ch2,
        "time_ch6" => data.ch3,
        "ch6" => data.ch4,
    )

    # Write the dict to a .mat file
    matwrite(folder, dict_data)

end