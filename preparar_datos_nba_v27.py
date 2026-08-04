"""
Script de preparacion de datos para juego Manager NBA
Fase 1-2: Descarga, cruce, escala de medias estilo NBA2K, nombres parecidos
a los reales, potencial y progresion.
"""

import os
import json
import random
import numpy as np
import pandas as pd


def descargar_datasets():
    if os.path.exists("data/stats") and os.listdir("data/stats"):
        print(" -> data/stats ya existe, se omite la descarga")
    else:
        os.system("kaggle datasets download -d sumitrodatta/nba-aba-baa-stats -p data/stats --unzip")

    if os.path.exists("data/draft") and os.listdir("data/draft"):
        print(" -> data/draft ya existe, se omite la descarga")
    else:
        os.system("kaggle datasets download -d wyattowalsh/basketball -p data/draft --unzip")


def cargar_stats(temporada_objetivo=2026, minimo_partidos=15):
    df = pd.read_csv("data/stats/Player Per Game.csv")
    df = df[df["season"] == temporada_objetivo].copy()
    df = df.reset_index(drop=True)
    df["_orden_original"] = df.index

    cols = ["player", "pos", "age", "team", "g", "gs", "pts_per_game",
            "trb_per_game", "ast_per_game", "stl_per_game", "blk_per_game",
            "x3pa_per_game", "_orden_original"]
    cols = [c for c in cols if c in df.columns]
    df = df[cols].dropna(subset=["player"])

    # Deteccion de traspasos: filas "2TM", "3TM", "4TM" tienen las
    # estadisticas combinadas de la temporada, pero el equipo real actual
    # del jugador es el de su ULTIMA fila individual (la mas reciente
    # cronologicamente, segun el orden del CSV de Basketball-Reference).
    es_combinada = df["team"].astype(str).str.match(r"^\d+TM$")
    df_combinadas = df[es_combinada].copy()
    df_individuales = df[~es_combinada].copy()

    if len(df_combinadas) > 0:
        ultimo_equipo = (
            df_individuales.sort_values("_orden_original")
            .groupby("player")["team"].last()
        )
        df_combinadas["team"] = df_combinadas["player"].map(ultimo_equipo).fillna(df_combinadas["team"])
        print(f"-> {len(df_combinadas)} jugadores traspasados, equipo actualizado al mas reciente")

    df_combinadas["_es_combinada"] = True
    df_individuales["_es_combinada"] = False
    df = pd.concat([df_combinadas, df_individuales], ignore_index=True)

    jugadores_con_combinada = set(df_combinadas["player"])
    df = df[~(df["player"].isin(jugadores_con_combinada) & ~df["_es_combinada"])]
    df = df.drop_duplicates(subset=["player"], keep="first")
    df = df.drop(columns=["_orden_original", "_es_combinada"], errors="ignore")

    try:
        shooting = pd.read_csv("data/stats/Player Shooting.csv")
        shooting = shooting[shooting["season"] == temporada_objetivo].copy()
        col_fg3_deseada = "fg_percent_from_x3p_range"
        cols_necesarias = ["player", "team"]
        if col_fg3_deseada in shooting.columns:
            cols_necesarias.append(col_fg3_deseada)

        shooting_reducido = shooting[cols_necesarias].copy()
        if "team" in shooting_reducido.columns:
            es_comb_s = shooting_reducido["team"].astype(str).str.match(r"^\d+TM$") | (shooting_reducido["team"] == "TOT")
            tiene_tot_s = shooting_reducido.groupby("player")["team"].transform(
                lambda x: (x.astype(str).str.match(r"^\d+TM$") | (x == "TOT")).any()
            )
            shooting_reducido = shooting_reducido[es_comb_s | ~tiene_tot_s]
        shooting_reducido = shooting_reducido.drop_duplicates(subset=["player"], keep="first")

        rename_map = {}
        if col_fg3_deseada in shooting_reducido.columns:
            rename_map[col_fg3_deseada] = "fg3_percent"
        shooting_reducido = shooting_reducido.rename(columns=rename_map)

        cols_finales = ["player"] + [v for v in rename_map.values()]
        df = df.merge(shooting_reducido[cols_finales], on="player", how="left")

        if "fg3_percent" not in df.columns:
            df["fg3_percent"] = 0

        if "x3pa_per_game" in df.columns:
            df["fg3_volumen"] = df["x3pa_per_game"]
            df["muestra_pequena"] = df["fg3_volumen"] < 1.0
            print(f"-> {df['muestra_pequena'].sum()} jugadores con volumen de triples muy bajo (menos de 1.0 intentos/partido)")
        else:
            df["fg3_volumen"] = 0
            df["muestra_pequena"] = True
            print("-> ADVERTENCIA: no se encontro x3pa_per_game, se marca a todos como bajo volumen")

    except FileNotFoundError:
        print("-> No se encontro Player Shooting.csv, se usan valores por defecto")
        df["fg3_percent"] = 0
        df["fg3_volumen"] = 0
        df["muestra_pequena"] = True

    print(f"-> {df['player'].duplicated().sum()} duplicados restantes tras deduplicar por traspasos")
    return df


def escala_2k(valores, n_total=None):
    serie = pd.Series(valores).fillna(0)
    n = n_total or len(serie)

    acumulado_95 = 8
    acumulado_90 = 22
    acumulado_83 = 95
    acumulado_80 = 95
    acumulado_75 = 95 + 180

    def pct_desde_arriba(acumulado):
        return max(0.0, 1 - acumulado / n)

    xp = [0.0,
          pct_desde_arriba(acumulado_75),
          pct_desde_arriba(acumulado_80),
          pct_desde_arriba(acumulado_83),
          pct_desde_arriba(acumulado_90),
          pct_desde_arriba(acumulado_95),
          1.0]
    fp = [35, 75, 80, 83, 90, 95, 99]

    for i in range(1, len(xp)):
        if xp[i] <= xp[i - 1]:
            xp[i] = xp[i - 1] + 1e-4

    percentiles = serie.rank(pct=True)
    resultado = np.interp(percentiles, xp, fp)
    return pd.Series(resultado, index=serie.index).round(0)


def escala_2k_por_posicion(valores, posiciones):
    serie = pd.Series(valores).fillna(0)
    pos_series = pd.Series(posiciones).reindex(serie.index).fillna("SF")
    pos_principal = pos_series.astype(str).str.split("-").str[0]

    resultado = pd.Series(index=serie.index, dtype=float)
    for pos in pos_principal.unique():
        mascara = pos_principal == pos
        sub_serie = serie[mascara]
        n_sub = len(sub_serie)
        if n_sub == 0:
            continue
        percentiles = sub_serie.rank(pct=True)
        xp_local = [0.0, 0.5, 0.75, 0.85, 0.93, 0.97, 1.0]
        fp_local = [35, 70, 80, 85, 90, 95, 99]
        resultado.loc[mascara] = np.interp(percentiles, xp_local, fp_local)

    return resultado.round(0)


def columna_segura(df, nombre):
    if nombre in df.columns:
        return df[nombre].fillna(0)
    return pd.Series(0, index=df.index)


UMBRAL_POR_POSICION = {
    "C": 3.0,
    "PF": 2.5,
    "SF": 2.0,
    "SG": 1.5,
    "PG": 1.5,
}

UMBRAL_DEFECTO = 2.0


def escala_tiro3(fg3_percent, fg3_intentos=None, posiciones=None):
    precision = pd.Series(fg3_percent).fillna(0)
    xp = [0.0, 0.05, 0.20, 0.28, 0.31, 0.33, 0.345, 0.35, 0.36, 0.39, 0.42, 0.50]
    fp = [20, 30, 40, 55, 65, 75, 82, 88, 91, 96, 99, 99]
    precision_rating = pd.Series(np.interp(precision, xp, fp), index=precision.index)

    if fg3_intentos is None:
        return precision_rating.round(0)

    intentos = pd.Series(fg3_intentos).fillna(0).reindex(precision_rating.index).fillna(0)
    volumen_rating = escala_2k(intentos, n_total=len(intentos))
    rating_mezclado = precision_rating * 0.65 + volumen_rating * 0.35

    if posiciones is not None:
        pos_series = pd.Series(posiciones).reindex(precision_rating.index)
        pos_principal = pos_series.astype(str).str.split("-").str[0]
        umbral_bajo = pos_principal.map(UMBRAL_POR_POSICION).fillna(UMBRAL_DEFECTO)
    else:
        umbral_bajo = pd.Series(UMBRAL_DEFECTO, index=precision_rating.index)

    techo_bajo_volumen = 55
    umbral_minimo = umbral_bajo * 0.3

    factor = (intentos / umbral_bajo).clip(0, 1)
    rating_con_techo = np.minimum(rating_mezclado, techo_bajo_volumen + (99 - techo_bajo_volumen) * factor)
    resultado = rating_con_techo.where(intentos >= umbral_minimo, np.minimum(rating_con_techo, 30))

    return resultado.round(0)


def calcular_atributos(df):
    print(" -> Columnas disponibles:", list(df.columns))
    n = len(df)

    fg3 = columna_segura(df, "fg3_percent")
    pts = columna_segura(df, "pts_per_game")
    stl = columna_segura(df, "stl_per_game")
    blk = columna_segura(df, "blk_per_game")
    ast = columna_segura(df, "ast_per_game")
    trb = columna_segura(df, "trb_per_game")
    fg3a = columna_segura(df, "x3pa_per_game") if "x3pa_per_game" in df.columns else None
    posiciones = df["pos"] if "pos" in df.columns else None

    ataque_raw = pts + ast * 1.5
    defensa_raw = stl * 2 + blk * 2 + trb * 0.8

    df["atr_tiro3"] = escala_tiro3(fg3, fg3a, posiciones)
    df["atr_ataque"] = escala_2k(ataque_raw, n_total=n)

    if posiciones is not None:
        df["atr_defensa"] = escala_2k_por_posicion(defensa_raw, posiciones)
    else:
        df["atr_defensa"] = escala_2k(defensa_raw, n_total=n)

    df["media"] = (
        df["atr_ataque"] * 0.55
        + df["atr_defensa"] * 0.40
        + df["atr_tiro3"] * 0.05
    ).round(0)

    df["pts_pg"] = pts.round(1)
    df["ast_pg"] = ast.round(1)
    df["trb_pg"] = trb.round(1)
    return df


def asignar_longevidad_y_retiro():
    factor_longevidad = round(random.triangular(0.5, 1.5, 1.0), 2)
    edad_retiro = round(random.triangular(34, 42, 37))
    return factor_longevidad, edad_retiro


def asignar_potencial(row):
    edad = row["age"]
    media = row["media"]
    espacio_libre = 99 - media

    if edad <= 22:
        margen = min(random.randint(5, 15), espacio_libre)
    elif edad <= 25:
        margen = min(random.randint(2, 10), espacio_libre)
    elif edad <= 29:
        margen = min(random.randint(-2, 4), espacio_libre)
    else:
        margen = random.randint(-8, 0)

    potencial = max(40, min(99, media + margen))
    return potencial


SUSTITUCIONES = {
    "a": ["a", "e"], "e": ["e", "i"], "o": ["o", "u"],
    "b": ["b", "p"], "v": ["v", "b"], "c": ["c", "k"],
    "s": ["s", "z"], "j": ["j", "y"], "d": ["d", "t"],
    "m": ["m", "n"], "r": ["r", "l"],
}


def mutar_palabra(palabra, intensidad=1):
    letras = list(palabra)
    posiciones = list(range(len(letras)))
    random.shuffle(posiciones)
    cambios = 0
    for pos in posiciones:
        letra = letras[pos].lower()
        if letra in SUSTITUCIONES and cambios < intensidad:
            opciones = [o for o in SUSTITUCIONES[letra] if o != letra]
            if opciones:
                nueva = random.choice(opciones)
                letras[pos] = nueva.upper() if letras[pos].isupper() else nueva
                cambios += 1
        if cambios >= intensidad:
            break
    return "".join(letras)


def generar_nombre_parecido(nombre_real, usados, letras_a_cambiar=2):
    if not isinstance(nombre_real, str) or nombre_real.strip() == "":
        nombre_real = "Player Unknown"
    partes = nombre_real.strip().split(" ")
    nombre_pila = partes[0]
    apellido = " ".join(partes[1:]) if len(partes) > 1 else "Smith"

    len_nombre = len(nombre_pila)
    len_apellido = len(apellido)
    total = len_nombre + len_apellido

    intentos = 0
    candidato = nombre_real
    while intentos < 30:
        if total > 0:
            intensidad_nombre = round(letras_a_cambiar * (len_nombre / total))
        else:
            intensidad_nombre = 0
        intensidad_apellido = letras_a_cambiar - intensidad_nombre

        nuevo_nombre = mutar_palabra(nombre_pila, intensidad=intensidad_nombre)
        nuevo_apellido = mutar_palabra(apellido, intensidad=intensidad_apellido)
        candidato = f"{nuevo_nombre} {nuevo_apellido}"
        if candidato not in usados:
            usados.add(candidato)
            return candidato
        intentos += 1
    candidato_final = f"{candidato} {random.randint(2, 99)}"
    usados.add(candidato_final)
    return candidato_final


def aplicar_nombres_parecidos(df):
    usados = set()
    df["nombre_ficticio"] = [generar_nombre_parecido(p, usados) for p in df["player"]]
    return df


def cargar_draft():
    """
    Carga datos de draft (anio de draft, pick, etc.) desde el dataset de Kaggle
    wyattowalsh/basketball y los reduce a una fila por jugador, lista para
    hacer merge por nombre.
    """
    draft = pd.read_csv("data/draft/csv/draft_history.csv")
    draft = draft.rename(columns={
        "player_name": "player",
        "season": "draft_year",
    })
    cols = [c for c in ["player", "draft_year", "overall_pick", "round_number"] if c in draft.columns]
    draft = draft[cols].dropna(subset=["player"])
    draft = draft.drop_duplicates(subset=["player"], keep="first")
    return draft


def exportar_json(df, ruta="output/jugadores.json"):
    os.makedirs("output", exist_ok=True)
    jugadores = []
    for _, row in df.iterrows():
        jugadores.append({
            "nombre": row["nombre_ficticio"],
            "nombre_real_base": row["player"],
            "posicion": row.get("pos", ""),
            "equipo": row.get("team", ""),
            "edad": int(row["age"]) if not pd.isna(row["age"]) else None,
            "atributos": {
                "tiro3": int(row["atr_tiro3"]),
                "ataque": int(row["atr_ataque"]),
                "defensa": int(row["atr_defensa"]),
            },
            "estadisticas": {
                "pts_pg": float(row["pts_pg"]),
                "ast_pg": float(row["ast_pg"]),
                "trb_pg": float(row["trb_pg"]),
            },
            "media": int(row["media"]),
            "potencial": int(row["potencial"]),
            "factor_longevidad": float(row["factor_longevidad"]),
            "edad_retiro": int(row["edad_retiro"]),
            "draft_year": row.get("draft_year", None),
        })
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(jugadores, f, ensure_ascii=False, indent=2)
    print(f"Exportado: {ruta} ({len(jugadores)} jugadores)")


if __name__ == "__main__":
    print("1) Descargando datasets de Kaggle...")
    descargar_datasets()

    print("2) Cargando y filtrando stats...")
    df = cargar_stats(temporada_objetivo=2026)

    print("3) Calculando atributos estilo NBA2K...")
    df = calcular_atributos(df)

    print("4) Asignando potencial oculto, longevidad y edad de retiro...")
    df["potencial"] = df.apply(asignar_potencial, axis=1)
    longevidad_retiro = df.apply(lambda r: asignar_longevidad_y_retiro(), axis=1)
    df["factor_longevidad"] = longevidad_retiro.apply(lambda x: x[0])
    df["edad_retiro"] = longevidad_retiro.apply(lambda x: x[1])

    print("5) Cruzando con datos de draft...")
    try:
        draft = cargar_draft()
        df = df.merge(draft, on="player", how="left")
    except Exception as e:
        print(f"Aviso: no se pudo cruzar draft ({e}). Continuando sin esos datos.")

    print("6) Generando nombres parecidos a los reales...")
    df = aplicar_nombres_parecidos(df)

    print("7) Exportando JSON final...")
    exportar_json(df)

    print("Listo. Pasa output/jugadores.json a Claude Code como base de datos del juego.")
