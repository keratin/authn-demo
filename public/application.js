(function() {
  /*
   * Integrate KeratinAuthN.signup
   */
  var signupForm = document.querySelector("form#signup");
  if (signupForm && !signupForm.classList.contains("incomplete")) {
    var username = signupForm.querySelector("input#user_email");
    var password = signupForm.querySelector("input#user_password");

    signupForm.addEventListener('submit', function (event) {
      event.preventDefault();

      // remove any existing error feedback. it's a clean slate!
      signupForm.querySelectorAll(".has-danger").forEach(function(e) {
        e.classList.remove('has-danger');
      });

      function submitWithoutKeratin() {
        signupForm.submit();
      }

      function showErrors(errorData) {
        errorData.forEach(function(data) {
          if (data.field === "username") {
            username.parentNode.classList.add("has-danger");
          } else if (data.field === "password") {
            password.parentNode.classList.add("has-danger");
          }
        });
      }

      KeratinAuthN
        .signup({ username: username.value, password: password.value })
        .then(submitWithoutKeratin, showErrors);
    })

  }

  /*
   * Integrate KeratinAuthN.logout
   */
  var logoutLink = document.querySelector("a#logout");
  if (logoutLink) {
    logoutLink.addEventListener('click', function (e) {
      e.preventDefault();

      KeratinAuthN.logout()
        .then(function () { window.location.href = '/'; });
    })
  }

  /*
   * Integrate KeratinAuthN.login
   */
  var loginForm = document.querySelector("form#login");
  if (loginForm) {
    var username = loginForm.querySelector("input#user_email");
    var password = loginForm.querySelector("input#user_password");

    loginForm.addEventListener('submit', function (event) {
      event.preventDefault();

      loginForm.querySelectorAll(".has-danger").forEach(function(e) {
        e.classList.remove('has-danger');
      });

      function goHome() {
        window.location.href = '/';
      }

      function showErrors() {
        username.parentNode.classList.add("has-danger");
        password.parentNode.classList.add("has-danger");
      }

      KeratinAuthN
        .login({ username: username.value, password: password.value })
        .then(goHome, showErrors);
    })
  }

  /*
   * Integrate KeratinAuthN.requestPasswordReset
   */
  var forgotForm = document.querySelector("form#forgot");
  if (forgotForm) {
    var username = forgotForm.querySelector("input#user_email");

    forgotForm.addEventListener('submit', function (event) {
      event.preventDefault();

      KeratinAuthN
        .requestPasswordReset(username.value)
        .then(function () {
          window.alert('An email has been sent to ' + username.value + ' with instructions to reset your password.');
        });
    });
  }

  /*
   * Password Resets
   */
  var resetForm = document.querySelector("form#reset");
  if (resetForm) {
    var password = resetForm.querySelector("input#user_password");
    var token = resetForm.querySelector("input#reset_token");

    function goHome() {
      window.location.href = '/';
    }

    function showErrors(errorData) {
      errorData.forEach(function(data) {
        if (data.field === "password") {
          password.parentNode.classList.add("has-danger");
        } else {
          window.alert(data.field + ' ' + data.message);
        }
      });
    }

    resetForm.addEventListener('submit', function (event) {
      event.preventDefault();

      KeratinAuthN
        .changePassword({password: password.value, token: token.value})
        .then(goHome, showErrors);
    });
  }

  /*
   * Password Updates
   */
  var changeForm = document.querySelector("form#changePassword");
  if (changeForm) {
    var currentPassword = changeForm.querySelector("input#current_password");
    var password = changeForm.querySelector("input#new_password");

    function resetFormAndCongratulate() {
      password.value = '';
      currentPassword.value = '';
      window.alert("Your password has been updated");
    }

    function showErrors(errorData) {
      errorData.forEach(function(data) {
        if (data.field === "password") {
          password.parentNode.classList.add("has-danger");
        } else {
          window.alert(data.field + ' ' + data.message);
        }
      });
    }

    changeForm.addEventListener('submit', function (event) {
      event.preventDefault();

      KeratinAuthN
        .changePassword({password: password.value, currentPassword: currentPassword.value})
        .then(resetFormAndCongratulate, showErrors);
    })
  }
})();
