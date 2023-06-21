using SMTPClient

function sendEmail(user, pwrd, host, rcpt)
    opt = SendOptions(
        isSSL=true,
        username=user,
        passwd=pwrd)
    #Provide the message body as RFC5322 within an IO
    # This is not working yet as it only sends an empty email, however it sends the email
    body = IOBuffer(
        "Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
        "From: You <natxofp@gmail.com>\r\n" *
        "To: fignasi@chalmers.se\r\n" *
        "Subject: PRC Test\r\n" *
        "\r\n" *
        "LUNA reading\r\n")
    from = "<natxofp@gmail.com>"
    # This is needed as the email is not sent otherwise, it fails sometimes the first time
    try
        send(host, rcpt, from, body, opt)
    catch e
        println(e)
        send(host, rcpt, from, body, opt)
    end
end