function validateForm() {
  var x = document.forms["upload-form"]["file"].value;
  if (x == "" || x == null) {
    alert("Complete all fields of the form.");
    return false;
  }
  return true;
}
