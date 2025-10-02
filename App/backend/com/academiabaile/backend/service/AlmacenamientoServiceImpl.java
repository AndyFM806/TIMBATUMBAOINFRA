    package com.academiabaile.backend.service;

    import com.cloudinary.Cloudinary;
    import com.cloudinary.utils.ObjectUtils;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.stereotype.Service;
    import org.springframework.web.multipart.MultipartFile;

    import java.io.IOException;
    import java.util.Map;

    @Service
    public class AlmacenamientoServiceImpl implements AlmacenamientoService {

        @Autowired
        private Cloudinary cloudinary;

        @Override
        public String guardar(MultipartFile archivo) {
            try {
                if (archivo.isEmpty()) {
                    throw new RuntimeException("Archivo vacío");
                }

                // Subir archivo a Cloudinary
                Map<?, ?> resultado = cloudinary.uploader().upload(archivo.getBytes(), ObjectUtils.emptyMap());

                // Retornar solo la URL segura
                return resultado.get("secure_url").toString();

            } catch (IOException e) {
                throw new RuntimeException("Error al subir el archivo a Cloudinary: " + e.getMessage(), e);
            }
                
        }
    }
