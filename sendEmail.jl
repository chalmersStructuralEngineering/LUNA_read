using SMTPClient

function sendEmail(user, pwrd, host)
    opt = SendOptions(
        isSSL=false,
        username=user,
        passwd=pwrd)
    #Provide the message body as RFC5322 within an IO
    body = IOBuffer(
        "Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
        "From: You <you@gmail.com>\r\n" *
        "To: fignasi@chalmers.se\r\n" *
        "Subject: PRC Test\r\n" *
        "\r\n" *
        "LUNA reading\r\n")
    rcpt = ["<fignasi@chalmers.se>"]
    from = "<fignasi@chalmers.se>"
    try
        send(host, rcpt, from, body, opt)
    catch e
        println(e)
        send(host, rcpt, from, body, opt)
    end
end