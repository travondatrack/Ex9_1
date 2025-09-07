<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Cookies</title>
    <link rel="stylesheet" href="styles/main.css" type="text/css" />
  </head>
  <body>
    <h1>Cookies</h1>

    <p>
      Here's a table with all of the cookies that this browser is sending to the
      current server.
    </p>

    <table>
      <tr>
        <th>Name</th>
        <th>Value</th>
      </tr>
      <c:forEach var="c" items="${cookie}">
        <tr>
          <td>${c.value.name}</td>
          <td>${c.value.value}</td>
        </tr>
      </c:forEach>
    </table>

    <p><a href="<c:url value='/list_albums.jsp' />">View list of albums</a></p>
    <p>
      <a href="<c:url value='/download?action=deleteCookies' />"
        >Delete all persistent cookies</a
      >
    </p>
  </body>
</html>
