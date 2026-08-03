# Tiesas Private Weapon Lab

Menú universal de pruebas visuales para experiencias Murder de Roblox. Está
diseñado para servidores privados y funciona sin una lista fija de `GameId`, por
lo que puede usarse en MM2, MMV, Murder Mystery Kids, MM Kids y otras variantes
que expongan modelos compatibles. Las armas se crean únicamente en el cliente,
no pueden atacar y no se guardan en el inventario.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/aleexx9123/tiesas-private-weapon-lab/main/loader.lua?cache=" .. tostring(os.time()), false))()
```

## Restricciones de seguridad

- Reconoce servidores privados mediante `PrivateServerId`.
- Si una experiencia oculta ese dato al cliente, continúa en modo local seguro
  en vez de bloquear el menú.
- También reconoce servidores VIP mediante `PrivateServerOwnerId` y pruebas en
  Roblox Studio; el loader desactiva la caché para no ejecutar versiones antiguas.
- No restringe la experiencia por nombre, creador ni `GameId`.
- El laboratorio visual principal no llama a `FireServer`, `InvokeServer`,
  DataStore ni sistemas de inventario.
- Elimina scripts y remotos de cada modelo antes de colocarlo en la mochila.
- Las copias desaparecen al salir o al cerrar el laboratorio.

El script busca modelos compatibles en `ReplicatedStorage` y `Workspace`. Los
nombres reconocidos incluyen Corrupt azul/Blue Corrupt, Luger azul/Blue Luger,
Voidscope/Void Scope y Ban Hammer.

## PoC del remoto de MMV

Esta prueba está limitada al universo `10354852672` y al lugar
`116924926476457`. Comprueba si `Remotes.Inventory.Equip` permite equipar
`Premium_K`, `Premium_G`, `Voidscope` o `BanHammer` sin que la entrada exista en
`Weapons.Owned`. No añade armas al inventario ni guarda datos.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/aleexx9123/tiesas-private-weapon-lab/main/mmv-loader.lua?cache=" .. tostring(os.time()), false))()
```
