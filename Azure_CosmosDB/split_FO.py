import time
import datetime

def split_FO(t_line):
    x_top=round((2.87097-0.08)*1000/5.2,0)
    x_bot=round((8.68025-0.08)*1000/5.2,0)
    x0=0.115
    
    numbers = t_line.split()

    mystring = ''
    mystring += numbers[0]+' ' + numbers[1]
    mystring = mystring[0:19]
    date_format = datetime.datetime.strptime(mystring,
                                         "%Y-%m-%d %H:%M:%S")
    time_s = datetime.datetime.timestamp(date_format)

    numbers_2 = numbers[4:]
    numbersFO=[float(i) for i in numbers_2]
    pos=int(x_top-round(x0*1000/5.2,0)+29)
    str_top=numbersFO[pos+1:pos+521]
    pos2=int(x_bot+round(x0*1000/5.2,0)-29)
    str_bot=numbersFO[pos2-521:pos2+1]
    str_bot.reverse()

    return (str_bot, str_top, time_s)