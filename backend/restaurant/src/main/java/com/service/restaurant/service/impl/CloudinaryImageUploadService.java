package com.service.restaurant.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.service.restaurant.exception.InvalidOperationException;
import com.service.restaurant.service.ImageUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CloudinaryImageUploadService implements ImageUploadService {
    private final Cloudinary cloudinary;

    @Override
    public String upload(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            throw new InvalidOperationException("Image file cannot be empty");
        }
        if (file.getContentType() == null || !file.getContentType().startsWith("image/")) {
            throw new InvalidOperationException("Only image files are allowed");
        }
        try {
            Map<?, ?> result = cloudinary.uploader().upload(
                    file.getBytes(), ObjectUtils.asMap("folder", folder, "resource_type", "image"));
            return result.get("secure_url").toString();
        } catch (IOException | RuntimeException ex) {
            throw new InvalidOperationException("Image upload failed", ex);
        }
    }
}
