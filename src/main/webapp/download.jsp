<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Downloads</title>
    <link rel="stylesheet" href="styles/main.css" type="text/css" />
  </head>
  <body>
    <h1>Downloads</h1>

    <h2>${product.description}</h2>

    <table>
      <tr>
        <th>Song title</th>
        <th>Audio Format</th>
      </tr>
      <c:forEach var="song" items="${product.songs}">
        <tr>
          <td>${song.title}</td>
          <td>
            <a href="downloadServlet?productCode=${song.productCode}">MP3</a>
          </td>
        </tr>
      </c:forEach>
    </table>

    <p><a href="<c:url value='/view_cookies.jsp' />">View all cookies</a></p>
    <p><a href="<c:url value='/list_albums.jsp' />">View list of albums</a></p>
  </body>
</html>
