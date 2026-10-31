package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.User;

import java.io.IOException;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.regex.Pattern;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

@WebServlet("/customer/orders/export/pdf")
public class ExportOrderPDFServlet extends HttpServlet {

    private static String stripVietnamese(String input) {
        if (input == null) return "";
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        String stripped = Pattern.compile("\\p{InCombiningDiacriticalMarks}+")
                      .matcher(normalized).replaceAll("");

        // Replace Vietnamese special base letters
        stripped = stripped.replace('Đ', 'D').replace('đ', 'd');
        stripped = stripped.replace('Ư', 'U').replace('ư', 'u');
        stripped = stripped.replace('Ô', 'O').replace('ô', 'o');
        stripped = stripped.replace('Ơ', 'O').replace('ơ', 'o');
        stripped = stripped.replace('Ă', 'A').replace('ă', 'a');

        return stripped;
    }

    private void drawText(PDPageContentStream cs, PDType1Font font, float size,
                          float x, float y, String text) throws IOException {
        cs.beginText();
        cs.setFont(font, size);
        cs.newLineAtOffset(x, y);
        cs.showText(stripVietnamese(text));
        cs.endText();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idRaw = request.getParameter("id");
        int orderID = 0;
        try {
            orderID = Integer.parseInt(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        OrderDAO odao = new OrderDAO();
        Order order = odao.getOrderByID(orderID);

        if (order == null || order.getUserID() != user.getUserID()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        ArrayList<OrderDetail> details = odao.getOrderDetails(orderID);
        ProductDAO pdao = new ProductDAO();

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"Order-" + orderID + ".pdf\"");

        try (PDDocument doc = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            doc.addPage(page);

            PDPageContentStream cs = new PDPageContentStream(doc, page);
            float margin = 50;
            float y = page.getMediaBox().getHeight() - margin;
            float pageWidth = page.getMediaBox().getWidth();

            PDType1Font fontBold    = PDType1Font.HELVETICA_BOLD;
            PDType1Font fontRegular = PDType1Font.HELVETICA;

            // --- HEADER ---
            drawText(cs, fontBold, 20, margin, y, "Electro Store");
            y -= 22;

            drawText(cs, fontRegular, 10, margin, y, "Laptop & Computer Store");
            y -= 30;

            cs.setLineWidth(1f);
            cs.moveTo(margin, y);
            cs.lineTo(pageWidth - margin, y);
            cs.stroke();
            y -= 20;

            // --- BILL TITLE ---
            drawText(cs, fontBold, 16, margin, y, "INVOICE - ORDER #" + orderID);
            y -= 25;

            drawText(cs, fontRegular, 10, margin, y,
                    "Date: " + (order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "N/A"));
            y -= 15;

            drawText(cs, fontRegular, 10, margin, y,
                    "Status: " + order.getStatus());
            y -= 15;

            drawText(cs, fontRegular, 10, margin, y,
                    "Customer: " + (user.getFullName() != null ? user.getFullName() : "N/A"));
            y -= 30;

            // --- TABLE HEADER ---
            float col1 = margin;
            float col2 = margin + 230;
            float col3 = margin + 310;
            float col4 = margin + 420;

            cs.setLineWidth(0.5f);
            cs.moveTo(margin, y);
            cs.lineTo(pageWidth - margin, y);
            cs.stroke();

            y -= 15;
            drawText(cs, fontBold, 10, col1, y, "Product");
            drawText(cs, fontBold, 10, col2, y, "Qty");
            drawText(cs, fontBold, 10, col3, y, "Price");
            drawText(cs, fontBold, 10, col4, y, "Total");
            y -= 15;

            cs.moveTo(margin, y);
            cs.lineTo(pageWidth - margin, y);
            cs.stroke();
            y -= 5;

            // --- TABLE ROWS ---
            double grandTotal = 0;
            for (OrderDetail od : details) {
                int pid = od.getProductID();
                String pname = "(Product)";
                Product p = pdao.getProductById(pid);
                if (p != null && p.getProductName() != null) {
                    pname = p.getProductName();
                }
                double lineTotal = od.getQuantity() * od.getPrice();
                grandTotal += lineTotal;

                if (pname.length() > 38) {
                    pname = pname.substring(0, 35) + "...";
                }

                y -= 18;
                if (y < 100) {
                    cs.close();
                    page = new PDPage(PDRectangle.A4);
                    doc.addPage(page);
                    cs = new PDPageContentStream(doc, page);
                    y = page.getMediaBox().getHeight() - margin;
                }

                drawText(cs, fontRegular, 9, col1, y, pname);
                drawText(cs, fontRegular, 9, col2, y, String.valueOf(od.getQuantity()));
                drawText(cs, fontRegular, 9, col3, y,
                        String.format("%.0f", od.getPrice()).replace(",", "."));
                drawText(cs, fontRegular, 9, col4, y,
                        String.format("%.0f", lineTotal).replace(",", "."));
            }

            y -= 10;
            cs.moveTo(margin, y);
            cs.lineTo(pageWidth - margin, y);
            cs.stroke();
            y -= 20;

            drawText(cs, fontBold, 12, col3, y, "TOTAL:");
            drawText(cs, fontBold, 12, col4, y,
                    String.format("%.0f VND", grandTotal).replace(",", "."));
            y -= 40;

            drawText(cs, fontRegular, 9, margin, y,
                    "Thank you for shopping at Electro Store!");
            y -= 15;
            drawText(cs, fontRegular, 9, margin, y, "Hotline: (+84) 123 456 789");

            cs.close();
            doc.save(response.getOutputStream());

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().print("Loi tao PDF: " + e.getMessage());
        }
    }
}
