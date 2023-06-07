import azure.cosmos.documents as documents
import azure.cosmos.cosmos_client as cosmos_client
import azure.cosmos.exceptions as exceptions
from azure.cosmos.partition_key import PartitionKey
from read_file import *
import datetime
import uuid
import config
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
with open('FO_str.json') as f:
    data = json.load(f)
str_top = get_FO_strTop(str(uuid.uuid1()), data['obj2'], time_s)
container.create_item(body=str_top)
str_bot = get_FO_strBot(str(uuid.uuid1()), data['obj1'], time_s)
container.create_item(body=str_bot)
