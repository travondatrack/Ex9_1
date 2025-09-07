package com.mycompany.ex9_1.servlets;

import java.io.Serializable;
import java.util.List;

public class Product implements Serializable {

    private String code;
    private String description;
    private List<Download> songs;

    public Product() {
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<Download> getSongs() {
        return songs;
    }

    public void setSongs(List<Download> songs) {
        this.songs = songs;
    }
}
