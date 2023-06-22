using MAT

function saveToMAT(data, time, folder)

    # Convert your struct to a dict of arrays
    dict_data = Dict(
        "ch1" => data.ch1,
        "ch2" => data.ch2,
        "ch3" => data.ch3,
        "ch4" => data.ch4,
        "time" => time
    )

    # Write the dict to a .mat file
    matwrite(folder, dict_data)

end