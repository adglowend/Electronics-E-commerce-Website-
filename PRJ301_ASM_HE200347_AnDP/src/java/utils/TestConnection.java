/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

/**
 *
 * @author Trung Hieu
 */

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        Connection conn = DBContext.getConnection();

        if (conn != null) {
            System.out.println("Ket noi thanh cong!");
        } else {
            System.out.println("Ket noi that bai!");
        }
    }
}
