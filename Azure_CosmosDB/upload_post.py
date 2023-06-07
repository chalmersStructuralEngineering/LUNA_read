import azure.cosmos.documents as documents
import azure.cosmos.cosmos_client as cosmos_client
import azure.cosmos.exceptions as exceptions
from azure.cosmos.partition_key import PartitionKey
from read_file import *
import datetime
import uuid
import config
#import matlab.engine
import numpy as np
import json
from split_FO import *
from read_JSON_funct import *

HOST = config.settings['host']
MASTER_KEY = config.settings['master_key']
DATABASE_ID = config.settings['database_id']
CONTAINER_ID = config.settings['container_id']
client = cosmos_client.CosmosClient(
    HOST, {'masterKey': MASTER_KEY}, user_agent="CosmosDBPythonQuickstart", user_agent_overwrite=True)
try:
    db = client.create_database(id=DATABASE_ID)
    print('Database with id \'{0}\' created'.format(DATABASE_ID))

except exceptions.CosmosResourceExistsError:
    db = client.get_database_client(DATABASE_ID)
    print('Database with id \'{0}\' was found'.format(DATABASE_ID))

    # setup container for this sample
try:
    container = db.create_container(
        id=CONTAINER_ID, partition_key=PartitionKey(path='/partitionKey'))
    print('Container with id \'{0}\' created'.format(CONTAINER_ID))

except exceptions.CosmosResourceExistsError:
    container = db.get_container_client(CONTAINER_ID)
    print('Container with id \'{0}\' was found'.format(CONTAINER_ID))

with open('time_stamp.json') as f:
    my_time = json.load(f)
date_format = datetime.datetime.strptime(my_time,
                                         "%Y-%m-%d %H:%M:%S")
time_s = datetime.datetime.timestamp(date_format)
with open('beam_1_results.json') as f:
    data = json.load(f)
plots_s = get_FO_plots_str(
    str(uuid.uuid1()), data['obj1'], data['obj2'], data['obj3'], time_s)
container.create_item(body=plots_s)
plots_cracks = get_FO_plots_crack(str(uuid.uuid1()), data['obj4'], time_s)
container.create_item(body=plots_cracks)
plots_defs = get_FO_plots_def(str(uuid.uuid1()), data['obj5'], time_s)
container.create_item(body=plots_defs)
with open('max_def.json') as f:
    max_def = json.load(f)
max_defs = get_FO_max_def(str(uuid.uuid1()), max_def, time_s)
container.create_item(body=max_defs)
with open('beam_1_plot_pos.json') as f:
    new_pos_obj = json.load(f)
new_pos = get_plot_newPos(str(uuid.uuid1()), new_pos_obj, time_s)
container.create_item(body=new_pos)
