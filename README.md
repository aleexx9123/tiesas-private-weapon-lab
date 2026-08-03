# Tiesas Private Weapon Lab

Menú universal de pruebas visuales para experiencias Murder de Roblox, limitado
a servidores privados. Funciona sin una lista fija de `GameId`, por lo que puede
usarse en MM2, MMV, Murder Mystery Kids, MM Kids y otras variantes que expongan
modelos compatibles. Las armas se crean únicamente en el cliente, no pueden
atacar y no se guardan en el inventario.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/aleexx9123/tiesas-private-weapon-lab/main/main.lua", true))()
```

## Restricciones de seguridad

- Requiere un servidor privado (`PrivateServerId`).
- Funciona para cualquier jugador que esté dentro de ese servidor privado.
- No restringe la experiencia por nombre, creador ni `GameId`.
- No llama a `FireServer`, `InvokeServer`, DataStore ni sistemas de inventario.
- Elimina scripts y remotos de cada modelo antes de colocarlo en la mochila.
- Las copias desaparecen al salir o al cerrar el laboratorio.

El script busca modelos compatibles en `ReplicatedStorage` y `Workspace`. Los
nombres reconocidos incluyen Corrupt azul/Blue Corrupt, Luger azul/Blue Luger,
Voidscope/Void Scope y Ban Hammer.
