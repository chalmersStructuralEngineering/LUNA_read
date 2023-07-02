using Downloads
using JSON3

function downloadFileFromSFTP(remote_path, user, pwrd, host)

    address = "sftp://" * user * ":" * pwrd * "@" * host * ":22" * remote_path
    try
        loads = JSON3.read(Downloads.download(address))
        return loads
    catch e
        println("Error downloading file from SFTP server")
        loads = zeros(1, 11)

        rcpt = ["<fignasi@chalmers.se>", "<david.dackman@chalmers.se>", "<berrocal@chalmers.se>"]
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"],
            ENV["SMTP_HOSTNAME_gm"], rcpt, "Error reading loads")

        return loads
    end

end