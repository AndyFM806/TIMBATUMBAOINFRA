document.addEventListener("DOMContentLoaded", () => {
  const usuario = sessionStorage.getItem("usuario");

  if (!usuario) {
    // No hay usuario logeado
    window.location.href = "../html/login.html";
  }
});
const user = JSON.parse(sessionStorage.getItem("usuario"));
if (user && document.getElementById("usuarioActivo")) {
  document.getElementById("usuarioActivo").textContent = `👤 ${user.nombreUsuario}`;
}
