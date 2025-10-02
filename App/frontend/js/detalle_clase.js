document.addEventListener('DOMContentLoaded', function () {
    const params = new URLSearchParams(window.location.search);
    const claseId = params.get('id');
  
    if (!claseId) {
      console.error("ID de clase no definido en la URL");
      return;
    }
  
    // Obtener info general de la clase
    fetch(`https://timbatumbao-back.onrender.com/api/clases`)
      .then(response => response.json())
      .then(clases => {
        const claseSeleccionada = clases.find(clase => clase.id === parseInt(claseId));
        if (!claseSeleccionada) {
          console.error("Clase no encontrada");
          return;
        }
  
        document.getElementById('nombre-clase').innerText = claseSeleccionada.nombre;
        document.getElementById('descripcion-clase').innerText = claseSeleccionada.descripcion;
      })
      .catch(error => console.error("Error cargando la clase:", error));
  
    // Obtener nivelaes desde clase_nivel (DTO plano)
    fetch(`https://timbatumbao-back.onrender.com/api/clases/${claseId}/niveles`)
  .then(response => response.json())
  .then(claseNiveles => {
    const contenedor = document.getElementById('niveles-clase');
    contenedor.innerHTML = "";

    claseNiveles.forEach(nivel => {
      const card = document.createElement('div');
      card.classList.add('card-clase');

      // Formatear horarios
      const horariosHTML = nivel.horarios.length > 0
        ? nivel.horarios.map(h => `<li>${h.dias} - ${h.hora}</li>`).join('')
        : `<li>No asignado</li>`;

      // Formatear fechas (puedes adaptarlas a formato local si deseas)
      const fechaInicio = new Date(nivel.fechaInicio).toLocaleDateString('es-PE');
      const fechaFin = new Date(nivel.fechaFin).toLocaleDateString('es-PE');
      const fechaCierre = new Date(nivel.fechaCierre).toLocaleDateString('es-PE');

      card.innerHTML = `
        <div style="padding: 1.5rem; border-radius: 12px; background: #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 1.5rem;">
          <h3 style="margin-top:0; color: #1a237e; font-size: 1.4rem; font-weight: 700;">${nivel.nivel.nombre}</h3>
          <div style="margin: 0.5rem 0 0.7rem 0;">
        <span style="display:inline-block; margin-right:1.2rem;"><strong>Aula:</strong> <span style="color:#3949ab">${nivel.aula.codigo}</span></span>
        <span style="display:inline-block; margin-right:1.2rem;"><strong>Aforo:</strong> <span style="color:#3949ab">${nivel.aforo}</span></span>
        <span style="display:inline-block;"><strong>Precio:</strong> <span style="color:#388e3c">S/${nivel.precio}</span></span>
          </div>
          <div style="margin-bottom: 0.5rem;">
        <strong>Duracion del Ciclo:</strong> <span style="color:#1565c0">${fechaInicio}</span> al <span style="color:#1565c0">${fechaFin}</span>
          </div>
          <div style="margin-bottom: 0.5rem;">
        <strong>Cierre de inscripciones:</strong> <span style="color:#d84315">${fechaCierre}</span>
          </div>
          <div style="margin-bottom: 0.5rem;">
        <strong>Horarios:</strong>
        <ul style="margin: 0.3rem 0 0 1.2rem; padding: 0; list-style: disc; color:#616161;">
          ${horariosHTML}
        </ul>
          </div>
          <a href="registro.html?id=${nivel.id}&nivel=${nivel.nivel.id}&precio=${nivel.precio}" 
         style="
            display:inline-block;
            margin-top:1rem;
            padding: 0.7rem 1.8rem;
            background: linear-gradient(90deg, #3949ab 60%, #1de9b6 100%);
            color: #fff;
            font-weight: 600;
            border-radius: 25px;
            text-decoration: none;
            box-shadow: 0 2px 6px rgba(30,136,229,0.12);
            transition: background 0.2s, transform 0.2s;
         "
         onmouseover="this.style.background='linear-gradient(90deg,#1de9b6 60%,#3949ab 100%)';this.style.transform='scale(1.04)'"
         onmouseout="this.style.background='linear-gradient(90deg,#3949ab 60%,#1de9b6 100%)';this.style.transform='scale(1)'"
          >Inscribirme</a>
        </div>
      `;

      contenedor.appendChild(card);
    });

    console.log("Respuesta del backend:", claseNiveles);
  })
  .catch(error => console.error("Error cargando los niveles:", error));

});
