package com.mycompany.ex9_1.servlets;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Download servlet for serving music files
 * Supports MP3 and M4A file formats with proper content headers
 */
@WebServlet(name = "DownloadServlet", urlPatterns = {"/downloadServlet"})
public class DownloadServlet extends HttpServlet {
    
    // Constants
    private static final int BUFFER_SIZE = 4096;
    private static final String MP3_CONTENT_TYPE = "audio/mpeg";
    private static final String M4A_CONTENT_TYPE = "audio/mp4";
    private static final String DEFAULT_CONTENT_TYPE = "application/octet-stream";
    private static final String ATTACHMENT_HEADER = "attachment; filename=\"%s\"";
    
    // Product mappings
    private static final Map<String, ProductInfo> PRODUCT_MAP = new HashMap<>();
    
    static {
        // 86 (the band) - True Life Songs and Pictures
        PRODUCT_MAP.put("8601", new ProductInfo(
            "86_band/you_are_a_star.mp3", 
            "86_Band-You_Are_A_Star.mp3"
        ));
        PRODUCT_MAP.put("8602", new ProductInfo(
            "86_band/dont_make_no_difference.mp3", 
            "86_Band-Dont_Make_No_Difference.mp3"
        ));
        
        // Paddlefoot - The First CD
        PRODUCT_MAP.put("pf0101", new ProductInfo(
            "paddlefoot_cd1/pete_and_jimmy.mp3", 
            "Paddlefoot-Pete_And_Jimmy.mp3"
        ));
        PRODUCT_MAP.put("pf0102", new ProductInfo(
            "paddlefoot_cd1/whiskey_before_breakfast.mp3", 
            "Paddlefoot-Whiskey_Before_Breakfast.mp3"
        ));
        
        // Paddlefoot - The Second CD
        PRODUCT_MAP.put("pf0201", new ProductInfo(
            "paddlefoot_cd2/neon_lights.m4a", 
            "Paddlefoot-Neon_Lights.m4a"
        ));
        PRODUCT_MAP.put("pf0202", new ProductInfo(
            "paddlefoot_cd2/just_about_midnight.m4a", 
            "Paddlefoot-Just_About_Midnight.m4a"
        ));
        
        // Joe Rut - Genuine Wood Grained Finish
        PRODUCT_MAP.put("jr0101", new ProductInfo(
            "joe_rut/wake_up_call.mp3", 
            "Joe_Rut-Wake_Up_Call.mp3"
        ));
        PRODUCT_MAP.put("jr0102", new ProductInfo(
            "joe_rut/wood_grained_finish.mp3", 
            "Joe_Rut-Wood_Grained_Finish.mp3"
        ));
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productCode = request.getParameter("productCode");
        
        if (productCode == null || productCode.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, 
                             "Product code is required");
            return;
        }
        
        ProductInfo productInfo = PRODUCT_MAP.get(productCode);
        if (productInfo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, 
                             "Invalid product code: " + productCode);
            return;
        }
        
        File file = getFileFromPath(productInfo.getFilePath());
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, 
                             "File not found: " + productInfo.getFilePath());
            return;
        }
        
        setResponseHeaders(response, file, productInfo);
        streamFileToResponse(file, response);
    }
    
    /**
     * Gets file object from the relative path
     */
    private File getFileFromPath(String fileName) {
        String filePath = getServletContext().getRealPath("/mp3/" + fileName);
        return new File(filePath);
    }
    
    /**
     * Sets appropriate response headers for file download
     */
    private void setResponseHeaders(HttpServletResponse response, File file, 
                                   ProductInfo productInfo) {
        String contentType = getContentType(productInfo.getFilePath());
        response.setContentType(contentType);
        response.setContentLength((int) file.length());
        
        String contentDisposition = String.format(ATTACHMENT_HEADER, 
                                                  productInfo.getDisplayName());
        response.setHeader("Content-Disposition", contentDisposition);
        
        // Additional headers for better download handling
        response.setHeader("Cache-Control", "must-revalidate, post-check=0, pre-check=0");
        response.setHeader("Pragma", "public");
    }
    
    /**
     * Streams file content to the response output stream
     */
    private void streamFileToResponse(File file, HttpServletResponse response) 
            throws IOException {
        try (FileInputStream fileIn = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            
            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;
            
            while ((bytesRead = fileIn.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
    
    /**
     * Determines content type based on file extension
     */
    private String getContentType(String fileName) {
        if (fileName.endsWith(".mp3")) {
            return MP3_CONTENT_TYPE;
        } else if (fileName.endsWith(".m4a")) {
            return M4A_CONTENT_TYPE;
        } else {
            return DEFAULT_CONTENT_TYPE;
        }
    }
    
    /**
     * Inner class to hold product information
     */
    private static class ProductInfo {
        private final String filePath;
        private final String displayName;
        
        public ProductInfo(String filePath, String displayName) {
            this.filePath = filePath;
            this.displayName = displayName;
        }
        
        public String getFilePath() {
            return filePath;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}
