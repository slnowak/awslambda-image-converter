from PIL import Image
from resizeimage import resizeimage

COVER_SIZE = [200, 150]
PROFILE_SIZE = [200, 200]
THUMBNAIL_SIZE = [250, 250]


def resize_to_cover(source_path, resized_path):
    _resize_image(source_path, resized_path, COVER_SIZE)


def resize_to_profile(source_path, resized_path):
    _resize_image(source_path, resized_path, PROFILE_SIZE)


def resize_to_thumbnail(source_path, resized_path):
    _resize_image(source_path, resized_path, THUMBNAIL_SIZE)


def _resize_image(source_path, resized_image_path, target_size):
    with Image.open(source_path) as image:
        img = resizeimage.resize_cover(image, target_size)
        img.save(resized_image_path, image.format)
