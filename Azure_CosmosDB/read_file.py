

def read_file():

    f = open('Balk 1.tsv','r')
    lines = f.readlines()

    n_list=lines[34::]
    new_l=n_list[::50]
    new_l=new_l[600::]

    return new_l

def get_FO_sensors(item_id, str_bot, str_top, time_s):
    # notice new fields have been added to the sales order
    raw_data = {'id' : item_id,
            'partitionKey' : 'raw_data',
            'strain bottom bar' : str_bot,
            'strain top bar' : str_top,
            'time stamp' : time_s,
            }
    #(locs,pos) = eng.findpeaks(np.asarray(str_bot))
    return raw_data