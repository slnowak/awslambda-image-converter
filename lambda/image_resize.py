import uuid

import boto3
from resizing import resize_to_cover, resize_to_profile, resize_to_thumbnail

s3_client = boto3.client('s3')


def handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), key)
        upload_path_cover = '/tmp/resized-{}'.format(key)
        upload_path_profile = '/tmp/resized-{}'.format(key)
        upload_path_thumbnail = '/tmp/resized-{}'.format(key)

        s3_client.download_file(bucket, key, download_path)

        resize_to_cover(download_path, upload_path_cover)
        s3_client.upload_file(upload_path_cover, '{bucket_name}cover'.format(bucket_name=bucket),
                              'cover-{key}'.format(key=key))

        resize_to_profile(download_path, upload_path_profile)
        s3_client.upload_file(upload_path_cover, '{bucket_name}profile'.format(bucket_name=bucket),
                              'profile-{key}'.format(key=key))

        resize_to_thumbnail(download_path, upload_path_thumbnail)
        s3_client.upload_file(upload_path_thumbnail, '{bucket_name}thumbnails'.format(bucket_name=bucket),
                              'thumbnail-{key}'.format(key=key))
