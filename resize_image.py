from PIL import Image
from resizeimage import resizeimage


def resize_image(source_path, resized_image_path, target_size):
    with Image.open(source_path) as image:
        cover = resizeimage.resize_cover(image, target_size)
        cover.save(resized_image_path, image.format)
