<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Download Registration</title>
    <link rel="stylesheet" href="styles/main.css" type="text/css" />
  </head>
  <body>
    <h1>Download registration</h1>

    <p>
      To register for our downloads, enter your name and email address below.
      Then, click on the Submit button.
    </p>

    <form action="download" method="post">
      <input type="hidden" name="action" value="registerUser" />
      <label>Email:</label>
      <input type="email" name="email" required /><br />

      <label>First Name:</label>
      <input type="text" name="firstName" required /><br />

      <label>Last Name:</label>
      <input type="text" name="lastName" required /><br />

      <input type="submit" value="Register" class="button" />
    </form>
  </body>
</html>
