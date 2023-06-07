def get_FO_strTop(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'name': 'raw FO data top',
            'partitionKey': 'raw_data',
            'data_type': 'strains',
            'FO_top': obj1,
            'time_stamp': ts,
            }
    return data


def get_FO_strBot(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'name': 'raw FO data bottom',
            'partitionKey': 'raw_data',
            'data_type': 'strains',
            'FD_bot': obj1,
            'time_stamp': ts,
            }
    return data


def get_FO_plots_str(item_id, obj1, obj2, obj3, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'strains',
            'plot_data': obj1,
            'top_bar_str': obj2,
            'bot_bar_str': obj3,
            'time_stamp': ts,
            }
    return data


def get_FO_plots_crack(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'cracks',
            'plot_data': obj1,
            'time_stamp': ts,
            }
    return data


def get_FO_plots_def(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'deflections',
            'plot_data': obj1,
            'time_stamp': ts,
            }
    return data


def get_FO_max_def(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'max_deflection',
            'plot_data': obj1,
            'units': 'mm',
            'time_stamp': ts,
            }
    return data


def get_plot_newPos(item_id, obj1, ts):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'positions',
            'plot_data': obj1,
            'units': 'mm',
            'time_stamp': ts,
            }
    return data


def get_plot_PosU(item_id, obj1):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'positions',
            'pos_upper': obj1,
            'units': 'mm',
            'time_stamp': 1,
            }
    return data


def get_plot_PosL(item_id, obj1):
    # notice new fields have been added to the sales order
    data = {'id': item_id,
            'partitionKey': 'plots',
            'data_type': 'positions',
            'pos_lower': obj1,
            'units': 'mm',
            'time_stamp': 1,
            }
    return data
