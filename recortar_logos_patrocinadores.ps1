# Recorta una hoja de contacto de patrocinadores (rejilla 5x3, con el nombre
# de la marca dentro de cada casilla) en 15 imagenes sueltas.
#
# La rejilla no se puede clavar con numeros fijos: las hojas vienen en dos
# tamanos (1024x559 y 1536x1024), con margenes distintos y algunas sin
# borde exterior. Se detectan las lineas separadoras y el resto se deduce.
#
# Como se reconoce una linea: es gris NEUTRO y bastante mas oscura que el
# fondo crema, pero no negra. El fondo se mide del propio fichero (varia de
# 241 a 252 de luminancia segun la hoja), asi que el umbral es relativo y no
# hay ningun 240 magico escrito a mano.
param(
  [Parameter(Mandatory=$true)][string]$Path,
  [string]$OutDir,
  [string]$Prefix,
  [int]$Alto = 260,
  [switch]$SoloMedir
)

Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile($Path)
$w = $img.Width
$h = $img.Height

$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$datos = $img.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
                       [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$stride = $datos.Stride
$px = New-Object byte[] ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($datos.Scan0, $px, 0, $px.Length)
$img.UnlockBits($datos)

# El fondo, medido en las cuatro esquinas (siempre son margen).
$xDer = $w - 4
$yAbajo = $h - 4
$puntos = @(@(3, 3), @($xDer, 3), @(3, $yAbajo), @($xDer, $yAbajo))
$esquinas = @()
foreach ($p in $puntos) {
  $o = $p[1] * $stride + $p[0] * 3
  $esquinas += (0.299 * $px[$o+2] + 0.587 * $px[$o+1] + 0.114 * $px[$o])
}
$fondo = ($esquinas | Measure-Object -Average).Average

$minLinea = $fondo - 90   # mas oscuro que esto ya es dibujo, no linea
$maxLinea = $fondo - 18   # mas claro que esto es el propio fondo
$maxCroma = 20            # una linea gris es neutra: R, G y B parecidos
$minFraccion = 0.85

function EsLinea([int]$o) {
  $b = $px[$o]; $g = $px[$o+1]; $r = $px[$o+2]
  $max = [math]::Max($r, [math]::Max($g, $b))
  $min = [math]::Min($r, [math]::Min($g, $b))
  if ($max - $min -gt $maxCroma) { return $false }
  $l = 0.299 * $r + 0.587 * $g + 0.114 * $b
  return ($l -ge $minLinea -and $l -le $maxLinea)
}

# Completa las lineas que la deteccion no vio.
#
# Hace falta porque no todas las hojas tienen las cuatro lineas visibles: a
# unas les falta el borde de abajo, a otras una vertical del medio que queda
# tapada por un logo que se sale de su casilla. Pero la rejilla es regular,
# asi que con las que SI se ven se deduce el paso y se rellenan las que
# faltan.
#
# Se prueban todos los pasos posibles (cada distancia entre dos lineas
# vistas, dividida entre 1, 2, 3...) y se elige la rejilla de [$n] lineas
# que cuadre con mas lineas reales. Las vistas mandan: la rejilla teorica
# solo se usa para los huecos, porque las hojas no son perfectamente
# regulares (en MIAMI la ultima fila mide 18 px menos que las otras dos).
function Completar($vistas, [int]$tam, [int]$n) {
  if ($vistas.Count -ge $n -or $vistas.Count -lt 2) { return $vistas }

  $pasos = @()
  for ($i = 0; $i -lt $vistas.Count; $i++) {
    for ($j = $i + 1; $j -lt $vistas.Count; $j++) {
      $d = $vistas[$j] - $vistas[$i]
      for ($k = 1; $k -lt $n; $k++) {
        $p = $d / $k
        if ($p -ge 60) { $pasos += $p }
      }
    }
  }

  $mejor = $null
  $mejorAciertos = -1
  foreach ($paso in $pasos) {
    foreach ($ancla in $vistas) {
      for ($desp = -($n - 1); $desp -le 0; $desp++) {
        $ini = $ancla + $desp * $paso
        $fin = $ini + ($n - 1) * $paso
        if ($ini -lt -4 -or $fin -gt $tam + 4) { continue }
        $aciertos = 0
        for ($k = 0; $k -lt $n; $k++) {
          $p = $ini + $k * $paso
          foreach ($v in $vistas) {
            if ([math]::Abs($v - $p) -le 5) { $aciertos++; break }
          }
        }
        if ($aciertos -gt $mejorAciertos) {
          $mejorAciertos = $aciertos
          $mejor = @(0..($n - 1) | ForEach-Object { $ini + $_ * $paso })
        }
      }
    }
  }
  if ($null -eq $mejor) { return $vistas }

  # La linea de verdad gana a la teorica siempre que exista.
  $final = @()
  foreach ($p in $mejor) {
    $cerca = $null
    foreach ($v in $vistas) {
      if ([math]::Abs($v - $p) -le 5) { $cerca = $v; break }
    }
    $final += [int]($(if ($null -ne $cerca) { $cerca } else { [math]::Max(0, [math]::Min($tam - 1, $p)) }))
  }
  return $final
}

function Agrupar($valores) {
  $grupos = @()
  $actual = @()
  foreach ($v in $valores) {
    if ($actual.Count -eq 0 -or $v -le $actual[-1] + 3) { $actual += $v }
    else { $grupos += ,@($actual); $actual = @($v) }
  }
  if ($actual.Count -gt 0) { $grupos += ,@($actual) }
  return @($grupos | ForEach-Object { [int](($_[0] + $_[-1]) / 2) })
}

# --- Lineas horizontales, mirando el ancho entero ---
$filas = @()
for ($y = 0; $y -lt $h; $y++) {
  $base = $y * $stride; $m = 0; $t = 0
  for ($x = 0; $x -lt $w; $x += 3) {
    $t++
    if (EsLinea ($base + $x * 3)) { $m++ }
  }
  if ($m / $t -ge $minFraccion) { $filas += $y }
}
$lineasY = @(Completar (Agrupar $filas) $h 4)

# --- Lineas verticales, mirando solo la banda de la rejilla ---
# (fuera de ella esta el titulo, que corta las columnas y las esconde)
$cols = @()
if ($lineasY.Count -ge 2) {
  $yIni = $lineasY[0] + 2
  $yFin = $lineasY[-1] - 2
  for ($x = 0; $x -lt $w; $x++) {
    $m = 0; $t = 0
    for ($y = $yIni; $y -le $yFin; $y += 3) {
      $t++
      if (EsLinea ($y * $stride + $x * 3)) { $m++ }
    }
    if ($t -gt 0 -and $m / $t -ge $minFraccion) { $cols += $x }
  }
}
$lineasX = @(Completar (Agrupar $cols) $w 6)

Write-Output ("{0}: {1}x{2} fondo={3} | Y: {4} | X: {5}" -f
  (Split-Path $Path -Leaf), $w, $h, [int]$fondo, ($lineasY -join ','), ($lineasX -join ','))

if ($SoloMedir) { $img.Dispose(); exit 0 }

if ($lineasY.Count -ne 4 -or $lineasX.Count -ne 6) {
  Write-Output "  !! la rejilla no cuadra (hacen falta 4 lineas Y y 6 X): no se recorta"
  $img.Dispose()
  exit 1
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality, 82)

$n = 0
for ($fila = 0; $fila -lt 3; $fila++) {
  for ($col = 0; $col -lt 5; $col++) {
    $n++
    $x0 = $lineasX[$col] + 2
    $x1 = $lineasX[$col + 1] - 2
    $y0 = $lineasY[$fila] + 2
    $y1 = $lineasY[$fila + 1] - 2
    $cw = $x1 - $x0
    $ch = $y1 - $y0

    $origen = New-Object System.Drawing.Rectangle $x0, $y0, $cw, $ch
    $escala = $Alto / $ch
    $destW = [int]($cw * $escala)

    $out = New-Object System.Drawing.Bitmap $destW, $Alto
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $destW, $Alto),
                 $origen, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    $out.Save((Join-Path $OutDir ("{0}_{1:d2}.jpg" -f $Prefix, $n)), $jpeg, $params)
    $out.Dispose()
  }
}

$img.Dispose()
Write-Output ("  15 recortes de {0} px de alto en {1}" -f $Alto, $OutDir)
