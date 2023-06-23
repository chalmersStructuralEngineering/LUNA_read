using FTPClient

function downloadFileToSFTP(filepath, remote_path, user, pwrd, host, rcpt)
    using FTPClient
    ftp_options = RequestOptions(hostname=host,
        username=user,
        password=pwrd,
        port=22,
        ssl=true,
        implicit=true,
        active_mode=false)


    ftp = FTP(ftp_options)  # Create a new FTP object
    ftp_get(ftp_options, "/data/stream.json")
    try
        # Open the file in binary mode and upload
        io = download(ftp, remote_path)  #

    catch e
        println("Failed to upload the file.")
        println(e)
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], rcpt, "Failed to upload file to FTP server!")
    finally
        # Remember to close the FTP connection
        close(ftp)
    end

end

using FTPClient
ftp_options = RequestOptions(hostname="129.16.170.231",
    username="admin",
    password="Sommarsol19",
    ssl=true)


ftp = FTP(ftp_options)  # Create a new FTP object
ftp_get(ftp_options, "/data/stream.json")

using Downloads
Downloads.Curl.PROTOCOL_STATUS["sftp"] = Downloads.Curl.status_zero_ok
Downloads.download("sftp://admin:Sommarsol19@129.16.170.231:22/data/stream.json")

