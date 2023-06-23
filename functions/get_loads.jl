using Downloads
using JSON3

function downloadFileFromSFTP(remote_path, user, pwrd, host)

    address = "sftp://" * user * ":" * pwrd * "@" * host * ":22" * remote_path
    try
        loads = JSON3.read(Downloads.download(address))
        return loads
    catch e
        println("Error downloading file from SFTP server")
        return nothing
    end

end