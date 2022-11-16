Asi qué, con calma:

Dia uno:
1: Comprar server Debian
2: Instalar: Openresty, postgresql, elasticsearch, redis
3: importar configuraciones de openresty (nginx) del desarollo, ajustar los caminos, y crear el puto certificado SSL
4: Crear una cuenta de usuario al propio booru, instalar elixir en ella via Kiex.
5: Clonar el responsitorio en carpeta /tsuchinokus
6: crear un script shell que ponga todas las variables del enviroment (nota, mirar cuales en docker-compose.yml)

Eso en 2-3 horas xD

Para ya toda la tarde:
1 mix local.rebar --force && mix local.hex --force
2 instalar todas las dependencias de Tsuchinokus como ffmpeg y whatnot, seguramente requiero del uso de fiberglass. No se me olvide, crear accesos rápidos a estos en /usr/local/bin
3 mix deps.get
4 mix release --overwrite
5 mix db:seed
6 Crear un usuario del servicio systemd que inicie el Tsuchinokus...
