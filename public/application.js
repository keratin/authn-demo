(function() {
  /*
   * Integrate KeratinAuthN.signup
   */
  var signupForm = document.querySelector("form#signup");
  if (signupForm) {
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
})();
