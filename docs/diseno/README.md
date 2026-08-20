# Maquetas del rediseño (registro histórico)

**Esto NO es la especificación de la interfaz.** Son las maquetas que se
hicieron *antes* de programar nada, para elegir entre dos direcciones. La
interfaz de verdad es el código: `lib/shared/estilo.dart` y las pantallas
de `lib/features/`.

Las maquetas se quedaron atrás a propósito. El juego tiene cosas que aquí
no salen, porque se decidieron al implementar:

- Las barras de los pasos obligatorios del verano van **sin flecha de
  volver** (ver `conVolver` en `estilo.dart`).
- Las mayúsculas son para los rótulos de interfaz, **no para la prosa** de
  los eventos narrativos.
- Los colores de las placas de media en **modo claro** se oscurecieron: los
  de estas maquetas no llegaban al contraste mínimo con su propio texto.

El porqué de cada decisión está en `docs/plan.md`, no aquí.

## Qué hay

| Fichero | Qué es |
|---|---|
| `Main.dc.html` | Menú principal, **dirección A ("Marcador")** — la elegida |
| `HubB.dc.html` | Menú principal, dirección B ("Cinemática") — descartada |
| `HubTablet.dc.html`, `HubEscritorio.dc.html` | La dirección A a 834 y 1280 px |
| `Plantilla.dc.html`, `PlantillaEscritorio.dc.html` | La pantalla de alineación |
| `canvas.json` | Cómo se colocan en el lienzo, con las notas de cada dirección |
| `_vista.plantilla.html` | La página que las presenta |
| `construir_vista.py` | Junta todo lo anterior en una sola página |

## Cómo verlas

```
python construir_vista.py
```

Genera `vista-previa.html`, que se abre en cualquier navegador sin
servidor. **No se guarda en git**: es un fichero derivado, y tenerlo al
lado de sus fuentes es guardar el mismo trabajo dos veces.

## Por qué son `.dc.html`

Se escribieron para el lienzo editable de Claude Design, que necesita
Node.js para ensamblarse y en esta máquina no lo hay. De ahí el script de
Python: hace lo mismo por la vía corta, a costa de que la página resultante
se mire pero no se toque.

Si algún día se quiere explorar otra dirección, estos ficheros son un punto
de partida que ya funciona: se copia uno, se cambia, y `construir_vista.py`
lo recoge (hay que añadirlo a la lista `PANTALLAS` del script).
