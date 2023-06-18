include("sendEmail.jl")

sendEmail(ENV["SMTP_USERNAME_ch"], ENV["SMTP_PASSWORD_ch"], ENV["SMTP_HOSTNAME_ch"])