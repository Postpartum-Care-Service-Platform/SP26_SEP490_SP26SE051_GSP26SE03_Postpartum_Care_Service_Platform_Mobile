class CloudinaryUtils {
  static String getOptimizedUrl(String url, {int? width, int? height}) {
    if (url.isEmpty || !url.contains('res.cloudinary.com')) return url;
    
    const uploadPath = '/image/upload/';
    final uploadIndex = url.indexOf(uploadPath);
    
    if (uploadIndex == -1) return url;
    
    // Create transformation string
    final w = width ?? 500;
    final h = height ?? 500;
    final transformations = 'w_$w,h_$h,c_fill,f_webp';
    
    // Check if it already has explicit general transformations right after upload/
    // We can just forcefully inject it safely since Cloudinary allows multiple transformations 
    // or chain them. e.g. /upload/w_500,h_500/v123/...
    String optimized = url.replaceFirst(uploadPath, '$uploadPath$transformations/');
    
    // If the image ends with .avif, change it to .webp to ensure compatibility, 
    // though f_webp transformation usually overrides the format anyway.
    if (optimized.endsWith('.avif')) {
      optimized = '${optimized.substring(0, optimized.length - 5)}.webp';
    }
    
    return optimized;
  }
}
