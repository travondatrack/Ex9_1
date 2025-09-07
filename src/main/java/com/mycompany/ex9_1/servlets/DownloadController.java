package com.mycompany.ex9_1.servlets;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DownloadController", urlPatterns = {"/download"})
public class DownloadController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "viewAlbums";  // default action
        }
        
        // perform action and set URL to appropriate page
        String url = "/list_albums.jsp";
        if (action.equals("viewAlbums")) {            
            url = "/list_albums.jsp";
        } else if (action.equals("checkUser")) {
            url = checkUser(request, response);
        } else if (action.equals("viewCookies")) {
            url = "/view_cookies.jsp";
        } else if (action.equals("deleteCookies")) {
            url = deleteCookies(request, response);
        }
        
        // forward to the view
        getServletContext()
                .getRequestDispatcher(url)
                .forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        // perform action and set URL to appropriate page
        String url = "/list_albums.jsp";
        if (action.equals("registerUser")) {
            url = registerUser(request, response);
        }
        
        // forward to the view
        getServletContext()
                .getRequestDispatcher(url)
                .forward(request, response);
    }
    
    private String checkUser(HttpServletRequest request,
            HttpServletResponse response) {
        
        String productCode = request.getParameter("productCode");
        HttpSession session = request.getSession();
        session.setAttribute("productCode", productCode);
        
        Cookie[] cookies = request.getCookies();
        String emailAddress = getCookieValue(cookies, "emailCookie");
        
        // If the cookie doesn't exist, go to the registration page
        if (emailAddress == null || emailAddress.equals("")) {
            return "/register.jsp";
        } else {
            Product product = getProduct(productCode);
            request.setAttribute("product", product);
            return "/download.jsp";
        }
    }
    
    private String registerUser(HttpServletRequest request,
            HttpServletResponse response) {
        
        // Get form data
        String email = request.getParameter("email");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        
        // Store user in a cookie
        Cookie c1 = new Cookie("emailCookie", email);
        c1.setMaxAge(60 * 60 * 24 * 365 * 2); // 2 years
        c1.setPath("/");
        response.addCookie(c1);
        
        Cookie c2 = new Cookie("firstNameCookie", firstName);
        c2.setMaxAge(60 * 60 * 24 * 365 * 2); // 2 years
        c2.setPath("/");
        response.addCookie(c2);
        
        // Retrieve product from session
        HttpSession session = request.getSession();
        String productCode = (String) session.getAttribute("productCode");
        
        // Create product and add to request
        Product product = getProduct(productCode);
        request.setAttribute("product", product);
        
        return "/download.jsp";
    }
    
    private String deleteCookies(HttpServletRequest request,
            HttpServletResponse response) {
        
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                cookie.setMaxAge(0);  // delete the cookie
                cookie.setPath("/");  // allow the download application to access it
                response.addCookie(cookie);
            }
        }
        return "/list_albums.jsp";
    }
    
    private String getCookieValue(Cookie[] cookies, String cookieName) {
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookieName.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return "";
    }
    
    // Create a Product object based on the product code
    private Product getProduct(String productCode) {
        Product product = new Product();
        if (productCode.equals("8601")) {
            product.setCode(productCode);
            product.setDescription("86 (the band) - True Life Songs and Pictures");
            
            List<Download> songs = new ArrayList<>();
            songs.add(new Download("8601", "You Are a Star", "MP3"));
            songs.add(new Download("8602", "Don't Make No Difference", "MP3"));
            product.setSongs(songs);
            
        } else if (productCode.equals("pf01")) {
            product.setCode(productCode);
            product.setDescription("Paddlefoot - The First CD");
            
            List<Download> songs = new ArrayList<>();
            songs.add(new Download("pf0101", "Pete and Jimmy", "MP3"));
            songs.add(new Download("pf0102", "Whiskey Before Breakfast", "MP3"));
            product.setSongs(songs);
            
        } else if (productCode.equals("pf02")) {
            product.setCode(productCode);
            product.setDescription("Paddlefoot - The Second CD");
            
            List<Download> songs = new ArrayList<>();
            songs.add(new Download("pf0201", "Neon Lights", "MP3"));
            songs.add(new Download("pf0202", "Just About Midnight", "MP3"));
            product.setSongs(songs);
            
        } else if (productCode.equals("jr01")) {
            product.setCode(productCode);
            product.setDescription("Joe Rut - Genuine Wood Grained Finish");
            
            List<Download> songs = new ArrayList<>();
            songs.add(new Download("jr0101", "Wake Up Call", "MP3"));
            songs.add(new Download("jr0102", "Wood Grained Finish", "MP3"));
            product.setSongs(songs);
        }
        
        return product;
    }
}
