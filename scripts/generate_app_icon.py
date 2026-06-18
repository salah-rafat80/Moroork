import os
from PIL import Image, ImageOps

def generate_app_icon():
    logo_path = 'assets/logo.png'
    output_path = 'assets/app_icon_generated.png'
    
    if not os.path.exists(logo_path):
        print(f"Error: {logo_path} not found.")
        return

    # Load logo
    logo = Image.open(logo_path)
    print(f"Original logo size: {logo.size}")

    # Crop transparent borders to get the actual logo content
    # If the image has an alpha channel, we can use its bounding box
    if logo.mode in ('RGBA', 'LA') or (logo.mode == 'P' and 'transparency' in logo.info):
        alpha = logo.split()[-1]
        bbox = alpha.getbbox()
        if bbox:
            logo = logo.crop(bbox)
            print(f"Cropped logo size: {logo.size}")

    # Create a 1024x1024 solid white background
    canvas_size = 1024
    icon_img = Image.new("RGBA", (canvas_size, canvas_size), (255, 255, 255, 255))

    # Calculate target dimensions for the logo inside the icon
    # We want it to be larger and wider.
    # Let's make the width about 80% of the canvas width (1024 * 0.8 = ~820 pixels)
    target_width = 820
    
    # Calculate height based on aspect ratio
    aspect_ratio = logo.width / logo.height
    target_height = int(target_width / aspect_ratio)
    
    # If target_height is too tall, scale down based on height instead
    if target_height > 820:
        target_height = 820
        target_width = int(target_height * aspect_ratio)

    print(f"Target logo dimensions (preserving aspect ratio): {target_width}x{target_height}")

    # Scale the logo using high-quality resampling
    resized_logo = logo.resize((target_width, target_height), Image.Resampling.LANCZOS)

    # Paste the resized logo into the center of the white canvas
    paste_x = (canvas_size - target_width) // 2
    paste_y = (canvas_size - target_height) // 2
    
    icon_img.paste(resized_logo, (paste_x, paste_y), resized_logo)

    # Convert to RGB (removing alpha channel) for standard app icons (especially iOS compatibility)
    final_icon = icon_img.convert("RGB")
    final_icon.save(output_path, "PNG")
    print(f"Generated launcher icon saved to {output_path}")

if __name__ == '__main__':
    generate_app_icon()
