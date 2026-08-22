<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ImageService
{
    /**
     * Resize & convert an uploaded image to WebP format, then save to specified disk & folder.
     *
     * @param UploadedFile $file
     * @param string $folder  e.g. 'payment-proofs', 'avatars', or 'settings'
     * @param string $disk    e.g. 'private' or 'public'
     * @param int $maxWidth   Max width in pixels (default: 1200)
     * @param int $quality    WebP quality 1-100 (default: 80)
     * @return string Path of the stored file (e.g. 'payment-proofs/abc-123.webp')
     */
    public function storeAsWebp(
        UploadedFile $file,
        string $folder = 'payment-proofs',
        string $disk = 'private',
        int $maxWidth = 1200,
        int $quality = 80
    ): string {
        $extension = strtolower($file->getClientOriginalExtension());
        $realPath = $file->getRealPath();

        // Load image using GD library
        $sourceImage = null;
        if (in_array($extension, ['jpg', 'jpeg'])) {
            $sourceImage = @imagecreatefromjpeg($realPath);
        } elseif ($extension === 'png') {
            $sourceImage = @imagecreatefrompng($realPath);
        } elseif ($extension === 'webp') {
            $sourceImage = @imagecreatefromwebp($realPath);
        }

        // Fallback: try imagecreatefromstring if extension-specific loader failed
        if (! $sourceImage && function_exists('imagecreatefromstring')) {
            $content = file_get_contents($realPath);
            $sourceImage = @imagecreatefromstring($content);
        }

        // If GD image loading failed, fallback to standard Laravel file store
        if (! $sourceImage) {
            return $file->store($folder, $disk);
        }

        $width = imagesx($sourceImage);
        $height = imagesy($sourceImage);

        // Resize image if width exceeds $maxWidth
        if ($width > $maxWidth) {
            $newWidth = $maxWidth;
            $newHeight = (int) round($height * ($maxWidth / $width));
            $targetImage = imagecreatetruecolor($newWidth, $newHeight);

            // Preserve alpha channel transparency for PNG/WebP
            imagealphablending($targetImage, false);
            imagesavealpha($targetImage, true);

            imagecopyresampled(
                $targetImage,
                $sourceImage,
                0, 0, 0, 0,
                $newWidth,
                $newHeight,
                $width,
                $height
            );

            imagedestroy($sourceImage);
            $sourceImage = $targetImage;
        }

        // Buffer WebP output
        ob_start();
        imagewebp($sourceImage, null, $quality);
        $webpData = ob_get_clean();
        imagedestroy($sourceImage);

        if (empty($webpData)) {
            return $file->store($folder, $disk);
        }

        // Generate clean unique filename with .webp extension
        $filename = $folder . '/' . Str::uuid() . '.webp';
        Storage::disk($disk)->put($filename, $webpData);

        return $filename;
    }
}
