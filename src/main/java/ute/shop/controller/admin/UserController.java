package ute.shop.controller.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import ute.shop.entity.User;
import ute.shop.services.IUserService;
import ute.shop.services.implement.UserServiceImpl;
import ute.shop.utils.SecurityAuditLogger;

@WebServlet(urlPatterns = { "/admin/userDetails", "/admin/updateUser", "/admin/addUser", "/admin/deleteUser" })
public class UserController extends HttpServlet{

	private static final long serialVersionUID = 1L;
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String url = req.getRequestURI();
		IUserService uservice = new UserServiceImpl();
		if (url.contains("Details")) {
			int user_id = Integer.parseInt(req.getParameter("id"));
			User user = uservice.findById(user_id);
			User actor = (User) req.getSession().getAttribute("account");
			SecurityAuditLogger.log("admin_action", req,
					SecurityAuditLogger.fields("actor", SecurityAuditLogger.actor(actor), "action",
							"user_details_view", "targetUserId", user_id));
			req.setAttribute("user", user);

			req.getRequestDispatcher("/views/admin/user.jsp").forward(req, resp);

		}
	}
}
