# -*- coding: utf-8 -*-
"""Anade al dataset los jugadores que la temporada 2025-26 dejo fuera.

El pipeline (preparar_datos_nba_v27.py) construye jugadores.json a partir
de las estadisticas de la temporada 2026 con un minimo de partidos. Quien
se perdio el ano ENTERO por lesion grave no tiene fila en el CSV de
origen, asi que desaparece del juego: no esta en jugadores.json ni en
datos_reales.json.

Sus atributos NO se inventan a ojo: se derivan de los jugadores del propio
dataset con un perfil de produccion parecido (mismo puesto, vecinos mas
cercanos por pts/ast/trb), y la media sale de la formula real del
pipeline. Antes de generar nada, el script se valida a si mismo con
leave-one-out sobre el dataset existente.
"""
import io
import json
import random
import statistics

RUTA = 'app/manager_nba/assets/data/jugadores.json'

# Formula del pipeline (calcular_atributos en preparar_datos_nba_v27.py).
PESO_ATAQUE, PESO_DEFENSA, PESO_TIRO3 = 0.55, 0.40, 0.05

# Escalas para normalizar la distancia entre perfiles de produccion. Son
# los rangos tipicos de cada estadistica: sin esto, los puntos (0-35)
# aplastarian a las asistencias (0-11) en la distancia euclidea.
ESCALA = {'pts_pg': 10.0, 'ast_pg': 4.0, 'trb_pg': 4.0}

ATRIBUTOS = ['atr_ataque', 'atr_defensa', 'atr_tiro3']


def base(posicion):
    """'PG-SG' -> 'PG'. El dataset trae alguna posicion compuesta."""
    return (posicion or '').split('-')[0].strip()


def distancia(a, b):
    total = 0.0
    for campo, escala in ESCALA.items():
        va, vb = a.get(campo), b.get(campo)
        if va is None or vb is None:
            return float('inf')
        total += ((va - vb) / escala) ** 2
    return total ** 0.5


def comparables(objetivo, poblacion, k=7):
    """Los k jugadores del mismo puesto con produccion mas parecida."""
    mismos = [j for j in poblacion
              if base(j['posicion']) == base(objetivo['posicion'])
              and all(j.get(c) is not None for c in ATRIBUTOS)
              and all(j.get(c) is not None for c in ESCALA)]
    mismos.sort(key=lambda j: distancia(objetivo, j))
    return mismos[:k]


def ataque_bruto(j):
    """ataque_raw del pipeline: pts + ast*1.5, antes de escalar."""
    return j['pts_pg'] + j['ast_pg'] * 1.5


def ataque_interpolado(objetivo, poblacion, k=15):
    """`atr_ataque` NO se estima por perfil completo: se reconstruye.

    El pipeline lo saca escalando `pts + ast*1.5` sobre toda la liga, y esa
    entrada la conocemos exacta para quien falta. Es el atributo que mas
    pesa en la media (0,55), asi que afinarlo es lo que de verdad cuenta.

    Se usa la MEDIANA de los k jugadores con `ataque_bruto` mas parecido,
    no una interpolacion punto a punto. La curva empirica es monotona en
    conjunto pero tiene picos sueltos (Trae Young marca 98 con un bruto de
    32,4, entre gente de 92); interpolando entre dos vecinos, caer al lado
    de uno de esos picos se lo lleva entero. La mediana de una ventana los
    ignora.
    """
    x = ataque_bruto(objetivo)
    validos = [j for j in poblacion
               if j.get('atr_ataque') is not None
               and j.get('pts_pg') is not None and j.get('ast_pg') is not None]
    validos.sort(key=lambda j: abs(ataque_bruto(j) - x))
    return statistics.median(j['atr_ataque'] for j in validos[:k])


def estimar(objetivo, poblacion, k=7):
    """Atributos y media estimados.

    Ataque: reconstruido de su formula. Defensa y tiro de tres: por
    vecinos, porque sus entradas (robos, tapones, % de triple) no viven en
    el JSON y no hay forma de reconstruirlas.
    """
    vecinos = comparables(objetivo, poblacion, k)
    if not vecinos:
        raise SystemExit('sin comparables para ' + objetivo['nombre_real'])
    est = {a: int(round(statistics.median(v[a] for v in vecinos)))
           for a in ('atr_defensa', 'atr_tiro3')}
    est['atr_ataque'] = int(round(ataque_interpolado(objetivo, poblacion)))
    est['media'] = int(round(
        est['atr_ataque'] * PESO_ATAQUE
        + est['atr_defensa'] * PESO_DEFENSA
        + est['atr_tiro3'] * PESO_TIRO3))
    est['_vecinos'] = [v['nombre_real'] for v in vecinos]
    return est


def validar(datos, k=7, muestra=120, semilla=20260819):
    """Leave-one-out: se estima la media de jugadores que YA estan, con el
    resto del dataset, y se mide el error. Si el metodo no reprodujera a
    los que si tenemos, tampoco valdria para los que faltan."""
    rng = random.Random(semilla)
    completos = [j for j in datos
                 if all(j.get(c) is not None for c in ATRIBUTOS)
                 and all(j.get(c) is not None for c in ESCALA)]
    elegidos = rng.sample(completos, min(muestra, len(completos)))
    errores = []
    for j in elegidos:
        resto = [o for o in completos if o is not j]
        est = estimar(j, resto, k)
        errores.append(abs(est['media'] - j['media']))
    errores.sort()
    return {
        'n': len(errores),
        'error_mediano': statistics.median(errores),
        'error_medio': round(statistics.mean(errores), 2),
        'p90': errores[int(len(errores) * 0.9) - 1],
        'peor': errores[-1],
    }


# --- Nombres ficticios: mismas reglas que el pipeline -------------------
SUSTITUCIONES = {
    "a": ["a", "e"], "e": ["e", "i"], "o": ["o", "u"],
    "b": ["b", "p"], "v": ["v", "b"], "c": ["c", "k"],
    "s": ["s", "z"], "j": ["j", "y"], "d": ["d", "t"],
    "m": ["m", "n"], "r": ["r", "l"],
}


def mutar_palabra(palabra, intensidad, rng):
    letras = list(palabra)
    posiciones = list(range(len(letras)))
    rng.shuffle(posiciones)
    cambios = 0
    for pos in posiciones:
        letra = letras[pos].lower()
        if letra in SUSTITUCIONES and cambios < intensidad:
            opciones = [o for o in SUSTITUCIONES[letra] if o != letra]
            if opciones:
                nueva = rng.choice(opciones)
                letras[pos] = nueva.upper() if letras[pos].isupper() else nueva
                cambios += 1
        if cambios >= intensidad:
            break
    return "".join(letras)


def nombre_parecido(nombre_real, usados, rng, letras_a_cambiar=2):
    partes = nombre_real.strip().split(" ")
    pila, apellido = partes[0], " ".join(partes[1:]) or "Smith"
    total = len(pila) + len(apellido)
    for _ in range(30):
        int_nombre = round(letras_a_cambiar * (len(pila) / total)) if total else 0
        candidato = (mutar_palabra(pila, int_nombre, rng) + " "
                     + mutar_palabra(apellido, letras_a_cambiar - int_nombre, rng))
        if candidato not in usados:
            usados.add(candidato)
            return candidato
    raise SystemExit('no se pudo generar nombre para ' + nombre_real)


def potencial_de(edad, media, rng):
    """asignar_potencial del pipeline, misma tabla por edad."""
    espacio = 99 - media
    if edad <= 22:
        margen = min(rng.randint(5, 15), espacio)
    elif edad <= 25:
        margen = min(rng.randint(2, 10), espacio)
    elif edad <= 29:
        margen = min(rng.randint(-2, 4), espacio)
    else:
        margen = rng.randint(-8, 0)
    return max(40, min(99, media + margen))


# --- Los que faltan ----------------------------------------------------
# Produccion de su ultima temporada sana (2024-25): es la referencia que
# usa el juego cuando no hay temporada simulada. La edad es la que les
# corresponde en 2025-26 con el criterio de Basketball-Reference (edad a
# 1 de febrero del ano en que acaba la temporada).
FALTANTES = [
    {'nombre_real': 'Kyrie Irving', 'posicion': 'PG', 'equipo': 'DAL',
     'edad': 33, 'pts_pg': 24.7, 'ast_pg': 4.6, 'trb_pg': 4.6,
     'draft_year': 2011},
    {'nombre_real': 'Damian Lillard', 'posicion': 'PG', 'equipo': 'POR',
     'edad': 35, 'pts_pg': 24.9, 'ast_pg': 7.1, 'trb_pg': 4.7,
     'draft_year': 2012},
    {'nombre_real': 'Tyrese Haliburton', 'posicion': 'PG', 'equipo': 'IND',
     'edad': 25, 'pts_pg': 18.6, 'ast_pg': 9.2, 'trb_pg': 3.5,
     'draft_year': 2020},
    {'nombre_real': 'Fred VanVleet', 'posicion': 'PG', 'equipo': 'HOU',
     'edad': 31, 'pts_pg': 14.1, 'ast_pg': 5.6, 'trb_pg': 3.7,
     'draft_year': None},
]


def main():
    datos = json.load(io.open(RUTA, encoding='utf-8'))
    print('jugadores en el dataset:', len(datos))

    v = validar(datos)
    print('\nValidacion leave-one-out sobre {n} jugadores existentes:'.format(**v))
    print('  error mediano de media: {error_mediano}'.format(**v))
    print('  error medio:            {error_medio}'.format(**v))
    print('  p90:                    {p90}'.format(**v))
    print('  peor caso:              {peor}'.format(**v))

    ya = {(j.get('nombre_real') or '').lower() for j in datos}
    usados = {j['nombre_ficticio'] for j in datos}
    rng = random.Random(20260819)

    nuevos = []
    for f in FALTANTES:
        if f['nombre_real'].lower() in ya:
            print('\n[ya estaba, se omite]', f['nombre_real'])
            continue
        est = estimar(f, datos)
        registro = {
            'nombre_ficticio': nombre_parecido(f['nombre_real'], usados, rng),
            'nombre_real': f['nombre_real'],
            'media': est['media'],
            'posicion': f['posicion'],
            'equipo': f['equipo'],
            'edad': f['edad'],
            'potencial': potencial_de(f['edad'], est['media'], rng),
            'atr_tiro3': est['atr_tiro3'],
            'atr_ataque': est['atr_ataque'],
            'atr_defensa': est['atr_defensa'],
            'pts_pg': f['pts_pg'],
            'ast_pg': f['ast_pg'],
            'trb_pg': f['trb_pg'],
            'factor_longevidad': round(rng.triangular(0.5, 1.5, 1.0), 2),
            'edad_retiro': round(rng.triangular(34, 42, 37)),
            'draft_year': f['draft_year'],
        }
        # Nadie se retira antes de la edad que ya tiene.
        registro['edad_retiro'] = max(registro['edad_retiro'], f['edad'] + 1)
        nuevos.append(registro)
        print('\n{nombre_real} ({equipo}, {edad} anos)'.format(**f))
        print('  media {media}  ataque {atr_ataque}  defensa {atr_defensa}'
              '  tiro3 {atr_tiro3}  potencial {potencial}'.format(**registro))
        print('  ficticio: ' + registro['nombre_ficticio'])
        print('  comparables: ' + ', '.join(est['_vecinos'][:5]))

    if not nuevos:
        print('\nNo hay nada que anadir.')
        return

    datos.extend(nuevos)
    with io.open(RUTA, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print('\nEscrito: %d jugadores en total (+%d)' % (len(datos), len(nuevos)))


if __name__ == '__main__':
    main()
