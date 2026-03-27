# Cómo contribuir a SimurToolsTB

## Estructura de ramas

```
master        → versión estable y publicada. Nadie trabaja aquí directamente.
develop       → rama de integración. Aquí se acumulan los trabajos revisados.
feature/*     → una rama por cada tarea o tema en desarrollo.
```

## Flujo de trabajo

### 1. Antes de empezar a trabajar

Asegúrate de partir siempre desde `develop` actualizado:

```bash
git checkout develop
git pull
git checkout -b feature/nombre-descriptivo
```

El nombre de la rama debe describir brevemente lo que se va a hacer, por ejemplo:
- `feature/deteccion-caidas`
- `feature/filtro-butterworth`
- `feature/refactor-eventos-cog`

### 2. Durante el desarrollo

Trabaja en tu rama `feature/*` con total libertad. Haz commits frecuentes y descriptivos:

```bash
git add archivo_modificado.m
git commit -m "Descripción breve de lo que hace este commit"
git push origin feature/nombre-descriptivo
```

### 3. Cuando termines

Abre un **Pull Request** en GitHub desde tu rama `feature/*` hacia `develop`:

1. Ve a [github.com/simurlab/SimurToolsTB](https://github.com/simurlab/SimurToolsTB)
2. Pulsa **"Compare & pull request"**
3. Asegúrate de que el destino es `develop` (no `master`)
4. Escribe un título claro y una descripción breve de los cambios
5. Los revisores (**juanuniovi** y **dalvarezuniovies**) recibirán la notificación automáticamente

### 4. Revisión y merge

- Al menos uno de los revisores debe aprobar el PR antes de hacer merge
- Si hay cambios solicitados, corrígelos en tu misma rama y vuelve a hacer push
- El merge lo realiza uno de los revisores

---

## Reglas básicas

| ✅ Permitido | ❌ No permitido |
|---|---|
| Commits directos en `feature/*` | Commits directos en `develop` o `master` |
| Abrir PRs hacia `develop` | Abrir PRs directamente hacia `master` |
| Crear tantas ramas `feature/*` como haga falta | Reutilizar ramas antiguas para temas distintos |

---

## Dudas

Habla con **juanuniovi** o **dalvarezuniovies**.
