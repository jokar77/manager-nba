# -*- coding: utf-8 -*-
"""Junta las seis maquetas .dc.html en una sola pagina que se puede abrir
en cualquier navegador.

Cada .dc.html trae su propio bloque <style> con nombres de clase que se
repiten entre ficheros (.cond, .rot, .badge...) y con valores distintos en
cada uno. Asi que aqui se le pone a cada maqueta un id propio y se le
prefija cada selector con ese id: sin eso, la .tile de la version de PC
pisaria la de la tablet y saldrian del tamano equivocado.
"""

import io
import os
import re

AQUI = os.path.dirname(os.path.abspath(__file__))

COLOR_EQUIPO = '#0E2240'
COLOR_ACENTO = '#FEC524'


def leer(nombre):
    with io.open(os.path.join(AQUI, nombre), encoding='utf-8') as f:
        return f.read()


def estilo_de(fuente):
    """El CSS del <helmet>, con cada selector metido dentro de la maqueta."""
    m = re.search(r'<style>(.*?)</style>', fuente, re.S)
    return m.group(1) if m else ''


def escalar_selectores(css, ambito):
    def repl(m):
        selectores = m.group(1).strip()
        cuerpo = m.group(2)
        partes = []
        for s in selectores.split(','):
            s = s.strip()
            if not s:
                continue
            # `body { ... }` define la tipografia y las variables de color
            # de la maqueta: le corresponde al contenedor, no a un hijo.
            partes.append(ambito if s == 'body' else '%s %s' % (ambito, s))
        return '%s {%s}' % (', '.join(partes), cuerpo)

    return re.sub(r'([^{}]+)\{([^{}]*)\}', repl, css)


def cuerpo_de(fuente):
    """Lo que hay entre </helmet> y </x-dc>: la maqueta en si."""
    ini = fuente.index('</helmet>') + len('</helmet>')
    fin = fuente.index('</x-dc>')
    cuerpo = fuente[ini:fin].strip()
    # Los huecos {{...}} los resuelve el motor de Claude Design; aqui se
    # sustituyen por los colores reales de Denver.
    cuerpo = cuerpo.replace('{{equipo}}', COLOR_EQUIPO)
    cuerpo = cuerpo.replace('{{acento}}', COLOR_ACENTO)
    return cuerpo


def maqueta(fichero, ident):
    fuente = leer(fichero)
    css = escalar_selectores(estilo_de(fuente), '#' + ident)
    # Las maquetas se dibujaron contando con border-box (hay filas con
    # ancho 100% y padding a la vez).
    css = '#%s, #%s * { box-sizing: border-box; }\n%s' % (ident, ident, css)
    return '<style>\n%s\n</style>\n<div class="maqueta" id="%s">\n%s\n</div>' % (
        css, ident, cuerpo_de(fuente))


PANTALLAS = [
    ('Main.dc.html', 'ab-a-movil'),
    ('HubB.dc.html', 'ab-b-movil'),
    ('HubTablet.dc.html', 'ab-tablet'),
    ('HubEscritorio.dc.html', 'ab-pc'),
    ('Plantilla.dc.html', 'ab-plantilla'),
    ('PlantillaEscritorio.dc.html', 'ab-plantilla-pc'),
]

partes = {ident: maqueta(fichero, ident) for fichero, ident in PANTALLAS}

plantilla = leer('_vista.plantilla.html')
for ident, html in partes.items():
    marca = '<!--%s-->' % ident
    assert marca in plantilla, 'falta la marca ' + marca
    plantilla = plantilla.replace(marca, html)

with io.open(os.path.join(AQUI, 'vista-previa.html'), 'w', encoding='utf-8') as f:
    f.write(plantilla)

print('vista-previa.html escrita:', len(plantilla), 'caracteres')
