import boto3
import logging
import sys

ACCESS_KEY_ID = 'IiHhaHC3rRktYOfFx29U'
SECRET_ACCESS_KEY = 'cxYB6BJ93q8kB2COH6CV4JLyZM/lNpVRiQfjoEv3'
TELEMETRY_COMMIT = '66ba8934eef37554d55e17efc8cc628ef2095868'

SERP_COMMIT = '2ee5e41fbb99468f248851e1eaa97933fefc5cae'

def get_key(commit):
    return 'web-test/{}/wpr_archive.tar'.format(commit)

# boto3.set_stream_logger('', logging.DEBUG)

session = boto3.session.Session(
    aws_access_key_id=ACCESS_KEY_ID,
    aws_secret_access_key=SECRET_ACCESS_KEY,
)
s3 = session.client(
    service_name='s3',
    endpoint_url='https://s3.mdst.yandex.net',
)

# Request all service's buckets
list_buckets_response = s3.list_buckets()
buckets = list_buckets_response['Buckets']
print buckets

# Create new service's bucket
bucket_name = 'pulse'
if not any(x['Name'] == bucket_name for x in buckets):
    s3.create_bucket(Bucket=bucket_name)

# Upload object to the service's bucket
if '--upload' in sys.argv:
    with open(sys.argv[1]) as f:
        s3.put_object(
            Bucket=bucket_name,
            Key=get_key(sys.argv[2]),
            Body=f)
elif '--delete' in sys.argv:
        s3.delete_object(
            Bucket=bucket_name,
            Key=get_key(sys.argv[2]))
        s3.delete_bucket(Bucket=bucket_name)
else:
    #print s3.list_objects(Bucket=bucket_name)
    get_object_response = s3.get_object(
        Bucket=bucket_name,
        Key=get_key(SERP_COMMIT),
    )
    print get_object_response
    zip_content = get_object_response['Body'].read()
    with open(sys.argv[1], 'w') as f:
        f.write(zip_content)
    #print s3.head_object(Bucket=bucket_name, Key=SERP_COMMIT)
    #obj = session.resource('s3').Object(bucket_name, SERP_COMMIT)
    #obj.load()
    #print obj.metadata
