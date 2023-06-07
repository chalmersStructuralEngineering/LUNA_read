import os

settings = {
    'host': os.environ.get('ACCOUNT_HOST', 'https://sensit.documents.azure.com:443/'),
    'master_key': os.environ.get('ACCOUNT_KEY', 'vSnfmNb3YYAzCTxwVMK2lQaroICMWW3hNauqjc6ROjEQHHduBToI4RlWXZLIplSxxeyGR0XBugm0ACDbmkaJxQ=='),
    'database_id': os.environ.get('COSMOS_DATABASE', 'KT_2023'),
    'container_id': os.environ.get('COSMOS_CONTAINER', 'Balk_1'),
}