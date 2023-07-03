using Downloads
using JSON3

function downloadFileFromSFTP(remote_path, user, pwrd, host)

    address = "sftp://" * user * ":" * pwrd * "@" * host * ":22" * remote_path
    try
        loads = JSON3.read(Downloads.download(address))
    catch e
        println("Error downloading file from SFTP server")
        loads = zeros(1, 11) * NaN
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"],
            ENV["SMTP_HOSTNAME_gm"],
            ["<fignasi@chalmers.se>", "<david.dackman@chalmers.se>", "<berrocal@chalmers.se>"],
            "Error reading loads")
    end
    return loads
end