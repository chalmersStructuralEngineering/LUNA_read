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


def upload_to_container(container, pos, pos2):
    container.create_item(body=pos)
    container.create_item(body=pos2)


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

with open('beam_1_pos_obj2.json') as f:
    pos_obj1 = json.load(f)
with open('beam_1_pos_obj3.json') as f:
    pos_obj2 = json.load(f)

pos1 = get_plot_PosU(str(uuid.uuid1()), pos_obj1)
pos2 = get_plot_PosL(str(uuid.uuid1()), pos_obj2)
upload_to_container(container, pos1, pos2)
