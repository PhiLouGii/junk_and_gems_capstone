import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Your actual image files and their product IDs
const imagesToUpload = [
  { productId: 1, localPath: '../assets/images/featured1.jpg', title: 'Fabric and Denim Patchwork Jacket' },
  { productId: 2, localPath: '../assets/images/featured2.jpg', title: 'Beer Bottle Lamp' },
  { productId: 3, localPath: '../assets/images/featured3.jpg', title: 'Sta-Soft Lamp' },
  { productId: 4, localPath: '../assets/images/featured4.jpg', title: 'Belt Patchwork Bag' },
  { productId: 5, localPath: '../assets/images/upcycled1.jpg', title: 'Denim Patchwork Bag' },
  { productId: 6, localPath: '../assets/images/featured6.jpg', title: 'Shoelace Table Coasters' },
  { productId: 13, localPath: '../assets/images/featured5.jpg', title: 'Broken China Mosaic' },
  { productId: 14, localPath: '../assets/images/featured7.jpg', title: 'Bottle Cap Soap Dish' },
  { productId: 15, localPath: '../assets/images/featured8.jpg', title: 'Shoprite Shower curtain' },
  { productId: 16, localPath: '../assets/images/featured9.jpg', title: 'Cassette Wall Art' }
];

const API_URL = 'https://junk-and-gems-api.onrender.com';

async function uploadImage(localPath) {
  try {
    const fullPath = path.join(__dirname, localPath);
    
    // Check if file exists
    if (!fs.existsSync(fullPath)) {
      console.log(`File not found: ${fullPath}`);
      return null;
    }

    // Read file as base64
    const imageBuffer = fs.readFileSync(fullPath);
    const base64Image = `data:image/jpeg;base64,${imageBuffer.toString('base64')}`;

    console.log(`Uploading ${localPath}...`);
    console.log(`   Size: ${(imageBuffer.length / 1024).toFixed(2)} KB`);

    // Upload to your server's Cloudinary endpoint
    const response = await fetch(`${API_URL}/api/upload-image`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        image_data_base64: base64Image
      })
    });

    const result = await response.json();

    if (result.success) {
      console.log(`Uploaded: ${result.image_url}`);
      return result.image_url;
    } else {
      console.log(`Upload failed: ${result.error || result.message}`);
      return null;
    }

  } catch (err) {
    console.error(`Error uploading ${localPath}:`, err.message);
    return null;
  }
}

async function updateProductImage(productId, imageUrl) {
  try {
    console.log(`Updating product ${productId} in database...`);

    const response = await fetch(`${API_URL}/api/products/${productId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        image_urls: JSON.stringify([imageUrl]), 
        image_data_base64: JSON.stringify([imageUrl]) 
      })
    });

    const result = await response.json();
    
    if (response.ok) {
      console.log(`Database updated for product ${productId}`);
      console.log(`Response:`, result);
    } else {
      console.log(`Database update failed:`, result);
    }
    
    return result;

  } catch (err) {
    console.error(`Error updating product ${productId}:`, err.message);
    return null;
  }
}

async function main() {
  console.log('Starting image upload process...');
  console.log('='.repeat(60));
  console.log(`Found ${imagesToUpload.length} images to upload`);
  console.log('='.repeat(60));

  const results = {
    success: [],
    failed: []
  };

  for (const item of imagesToUpload) {
    console.log(`\n Processing: ${item.title} (Product ${item.productId})`);
    
    // Upload image
    const cloudinaryUrl = await uploadImage(item.localPath);

    if (cloudinaryUrl) {
      // Update database
      await updateProductImage(item.productId, cloudinaryUrl);
      results.success.push(item);
      
      // Wait 1 second between uploads to avoid rate limits
      await new Promise(resolve => setTimeout(resolve, 1000));
    } else {
      results.failed.push(item);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('UPLOAD COMPLETE!');
  console.log('='.repeat(60));
  console.log(`Successful: ${results.success.length}`);
  console.log(`Failed: ${results.failed.length}`);
  
  if (results.failed.length > 0) {
    console.log('\n Failed uploads:');
    results.failed.forEach(item => {
      console.log(`   - ${item.localPath} (Product ${item.productId})`);
    });
  }
}

// Run the script
main().catch(console.error);