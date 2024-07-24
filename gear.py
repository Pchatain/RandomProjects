"""
This file randomly assigns a shirt and a short to wear for the day
"""

import os
import random
from PIL import Image, ImageDraw, ImageFont

def draw_text(image, text, position):
    # Initialize ImageDraw
    draw = ImageDraw.Draw(image)
    
    # You can specify a font file if you want a specific font style
    font = ImageFont.load_default()
    
    # Draw the text
    draw.text(position, text, (255, 255, 255), font=font)

def main():
    shirts = os.listdir("gear/shirts")
    shorts = os.listdir("gear/shorts")
    
    shirt = random.choice(shirts)
    short = random.choice(shorts)
    
    # get the image of the shirt and short
    shirt_img = Image.open(f"gear/shirts/{shirt}")
    short_img = Image.open(f"gear/shorts/{short}")
    
    
    # create a new image with the shirt and short
    new_img = Image.new("RGB", (max(shirt_img.width, short_img.width), shirt_img.height + short_img.height + 40))
    new_img.paste(shirt_img, (0, 0))
    new_img.paste(short_img, (0, shirt_img.height))
    
    # Draw the filenames onto the new image
    draw_text(new_img, shirt, (10, shirt_img.height + short_img.height + 10))
    draw_text(new_img, short, (10, shirt_img.height + short_img.height + 30))
    
    new_img.show()

if __name__ == "__main__":
    main()