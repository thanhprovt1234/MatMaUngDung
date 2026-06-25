package ute.shop.controller.guest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import ute.shop.dao.guest.implement.UserDAO;
import ute.shop.entity.User;
import ute.shop.services.guest.implement.UserService;
import ute.shop.utils.md5;
import ute.shop.utils.BCryptUtils;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

@WebServlet(urlPatterns = { "/register", "/guest/register" })
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService(new UserDAO());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Lấy thông tin từ form
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";
        String rePassword = request.getParameter("re-password") != null ? request.getParameter("re-password").trim()
                : "";
        String firstname = request.getParameter("firstname") != null ? request.getParameter("firstname").trim() : "";
        String lastname = request.getParameter("lastname") != null ? request.getParameter("lastname").trim() : "";

        // Kiểm tra mật khẩu nhập lại
        if (!password.equals(rePassword)) {
            request.setAttribute("message", "Mật khẩu nhập lại không khớp.");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        // Kiểm tra độ mạnh mật khẩu (Ít nhất 1 hoa, 1 số, 1 đặc biệt, 8 ký tự)
        String passwordPattern = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$";
        if (!password.matches(passwordPattern)) {
            request.setAttribute("message",
                    "Mật khẩu phải có ít nhất 8 ký tự, bao gồm 1 chữ hoa, 1 số và 1 ký tự đặc biệt (@$!%*?&)");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        String hashedPassword = BCryptUtils.hashPassword(password);

        // Tạo đối tượng User mới
        User newUser = new User();
        newUser.setEmail(email);
        newUser.setPassword(hashedPassword);
        newUser.setFirstname(firstname);
        newUser.setLastname(lastname);

        try {
            // Đăng ký người dùng
            userService.registerUser(newUser);
            request.setAttribute("message", "Đăng ký thành công!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("message", e.getMessage());
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }
}
