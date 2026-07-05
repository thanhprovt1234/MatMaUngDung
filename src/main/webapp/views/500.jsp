<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Server Error</title>
</head>
<body>
	<h1>Server Error</h1>
	<p>An unexpected error occurred while processing your request.</p>
	<%
		Throwable error = exception;
		if (error == null) {
			error = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
		}
		if (error != null) {
	%>
	<p><strong><%=error.getClass().getSimpleName()%>:</strong> <%=error.getMessage()%></p>
	<%
		}
	%>
	<p><a href="${pageContext.request.contextPath}/home">Back to home</a></p>
</body>
</html>
