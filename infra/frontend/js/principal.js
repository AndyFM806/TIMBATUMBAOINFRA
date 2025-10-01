document.addEventListener('DOMContentLoaded', () => {
  const contenedor = document.getElementById('lista-clases');
  fetch('https://timbatumbao-back.onrender.com/api/clase-nivel/clases-con-niveles-abiertos')
    .then(response => response.json())
    .then(clases => {
      if (clases.length === 0) {
        contenedor.innerHTML = "<p>No hay clases disponibles por ahora.</p>";
        return;
      }

      clases.forEach(clase => {
        const card = document.createElement('div');
        card.classList.add('card-clase');

        const fecha = new Date(clase.fechaInicio || clase.fecha);
        const fechaBonita = fecha.toLocaleDateString('es-PE', {
          year: 'numeric', month: 'long', day: 'numeric'
        });

        card.innerHTML = `
          <div style="padding: 1.1rem; border-radius: 14px; background: #fff; box-shadow: 0 2px 10px rgba(30,41,59,0.10); margin: 1rem auto 1.5rem auto; border: 1px solid #e3e7fd; max-width: 340px; text-align: center;">
            <div style="margin-bottom: 0.8rem;">
              <h3 style="margin:0; color: #1a237e; font-size: 1.18rem; font-weight: 700; letter-spacing:0.01em;">${clase.nombre}</h3>
            </div>
            <div style="margin-bottom: 1rem;">
              <p style="margin:0; color:#374151; font-size:1.01rem; line-height:1.5;">${clase.descripcion}</p>
            </div>
            <div style="display: flex; justify-content: center;">
              <a href="detalle_clase.html?id=${clase.id}" 
          style="
            display:inline-block;
            padding: 0.6rem 1.7rem;
            background: linear-gradient(90deg, #3949ab 60%, #1de9b6 100%);
            color: #fff;
            font-weight: 600;
            border-radius: 25px;
            text-decoration: none;
            box-shadow: 0 2px 8px rgba(30,136,229,0.13);
            transition: background 0.2s, transform 0.2s;
            font-size: 1.01rem;
            letter-spacing: 0.01em;
            border: none;
            outline: none;
            cursor: pointer;
          "
          onmouseover="this.style.background='linear-gradient(90deg,#1de9b6 60%,#3949ab 100%)';this.style.transform='scale(1.04)'"
          onmouseout="this.style.background='linear-gradient(90deg,#3949ab 60%,#1de9b6 100%)';this.style.transform='scale(1)'"
              >Ver detalles</a>
            </div>
          </div>
        `;

        contenedor.appendChild(card);
      });
    })
    .catch(error => {
      contenedor.innerHTML = "<p>Error al cargar clases. Intenta más tarde.</p>";
      console.error('Error al obtener clases:', error);
    });

  //Carrusel infinito REAL
  const track = document.getElementById('carrusel-track');
  const btnIzq = document.querySelector('.flecha.izquierda');
  const btnDer = document.querySelector('.flecha.derecha');

  let posicion = 0;

  const duplicarItems = () => {
    const tarjetas = Array.from(track.children);
    tarjetas.forEach(card => {
      const clon1 = card.cloneNode(true);
      const clon2 = card.cloneNode(true);
      track.appendChild(clon1);       // al final
      track.insertBefore(clon2, track.firstChild); // al inicio
    });
    posicion = tarjetas.length; // empezamos desde la mitad
    actualizarDesplazamiento();
  };

  const actualizarDesplazamiento = () => {
    const tarjeta = track.querySelector('.tarjeta-estilo');
    if (!tarjeta) return;

    const tarjetaWidth = tarjeta.offsetWidth + 20;
    track.style.transition = 'transform 0.4s ease-in-out';
    track.style.transform = `translateX(-${posicion * tarjetaWidth}px)`;
  };

  const tarjetaWidthCalc = () => {
    const tarjeta = track.querySelector('.tarjeta-estilo');
    return tarjeta ? tarjeta.offsetWidth + 20 : 320;
  };

  const avanzar = () => {
    const tarjetaWidth = tarjetaWidthCalc();
    const total = track.children.length;
    posicion++;
    actualizarDesplazamiento();

    // Reset al medio si llegamos al final virtual
    setTimeout(() => {
      if (posicion >= total - 3) {
        posicion = total / 2;
        track.style.transition = 'none';
        track.style.transform = `translateX(-${posicion * tarjetaWidth}px)`;
      }
    }, 410);
  };

  const retroceder = () => {
    const tarjetaWidth = tarjetaWidthCalc();
    posicion--;
    actualizarDesplazamiento();

    // Reset al medio si llegamos al inicio virtual
    setTimeout(() => {
      if (posicion <= 2) {
        posicion = track.children.length / 2;
        track.style.transition = 'none';
        track.style.transform = `translateX(-${posicion * tarjetaWidth}px)`;
      }
    }, 410);
  };

  if (track && btnIzq && btnDer) {
    duplicarItems(); // Clona para crear efecto infinito

    btnDer.addEventListener('click', avanzar);
    btnIzq.addEventListener('click', retroceder);

    window.addEventListener('resize', actualizarDesplazamiento);
  }
});
