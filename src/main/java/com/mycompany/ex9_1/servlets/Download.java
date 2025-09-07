package com.mycompany.ex9_1.servlets;

import java.io.Serializable;

public class Download implements Serializable {

    private String productCode;
    private String title;
    private String format;

    public Download() {
    }

    public Download(String productCode, String title, String format) {
        this.productCode = productCode;
        this.title = title;
        this.format = format;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }
}
