<?php

namespace Tests\Unit;

use App\Services\ImageService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ImageServiceTest extends TestCase
{
    public function test_image_service_resizes_landscape_png_to_webp(): void
    {
        Storage::fake('private');

        // Fake 2000x1000 landscape PNG
        $fakeFile = UploadedFile::fake()->image('landscape.png', 2000, 1000);

        $imageService = new ImageService();
        $storedPath = $imageService->storeAsWebp(
            file: $fakeFile,
            folder: 'payment-proofs',
            disk: 'private',
            maxWidth: 1200,
            quality: 80
        );

        $this->assertStringEndsWith('.webp', $storedPath);
        Storage::disk('private')->assertExists($storedPath);

        $content = Storage::disk('private')->get($storedPath);
        $gdImage = imagecreatefromstring($content);

        $this->assertNotFalse($gdImage);
        $this->assertEquals(1200, imagesx($gdImage));
        $this->assertEquals(600, imagesy($gdImage));

        imagedestroy($gdImage);
    }

    public function test_image_service_resizes_portrait_jpeg_to_webp(): void
    {
        Storage::fake('public');

        // Fake 2000x3000 portrait JPG
        $fakeFile = UploadedFile::fake()->image('portrait.jpg', 2000, 3000);

        $imageService = new ImageService();
        $storedPath = $imageService->storeAsWebp(
            file: $fakeFile,
            folder: 'avatars',
            disk: 'public',
            maxWidth: 500,
            quality: 80
        );

        $this->assertStringEndsWith('.webp', $storedPath);
        Storage::disk('public')->assertExists($storedPath);

        $content = Storage::disk('public')->get($storedPath);
        $gdImage = imagecreatefromstring($content);

        $this->assertNotFalse($gdImage);
        $this->assertEquals(500, imagesx($gdImage));
        $this->assertEquals(750, imagesy($gdImage));

        imagedestroy($gdImage);
    }

    public function test_image_service_keeps_small_image_dimensions_unchanged(): void
    {
        Storage::fake('public');

        // Small 300x300 image (less than maxWidth 1200)
        $fakeFile = UploadedFile::fake()->image('small.png', 300, 300);

        $imageService = new ImageService();
        $storedPath = $imageService->storeAsWebp(
            file: $fakeFile,
            folder: 'settings',
            disk: 'public',
            maxWidth: 1200,
            quality: 85
        );

        $this->assertStringEndsWith('.webp', $storedPath);

        $content = Storage::disk('public')->get($storedPath);
        $gdImage = imagecreatefromstring($content);

        $this->assertNotFalse($gdImage);
        $this->assertEquals(300, imagesx($gdImage));
        $this->assertEquals(300, imagesy($gdImage));

        imagedestroy($gdImage);
    }
}
