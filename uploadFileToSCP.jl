function uploadFileToSCP(local_path, remote_path, username, hostname; key_path=nothing)
    scp_cmd = if key_path !== nothing
        `scp -i $key_path $local_path $username@$hostname:$remote_path`
    else
        `scp $local_path $username@$hostname:$remote_path`
    end

    try
        run(scp_cmd)
        println("File uploaded successfully.")
    catch e
        println("Failed to upload the file.")
        println(e)
    end
end


