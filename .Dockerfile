# Utilizamos una imagen base con el SDK de .NET Core para compilar la aplicación
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos necesarios para compilar (asegúrate de que todos están en la misma carpeta que tu Dockerfile)
COPY ./properties/launchSettings ./properties/launchSettings
COPY ./appsettings.development ./appsettings.development
COPY ./simpleqrGenerator.sln ./simpleqrGenerator.sln
COPY ./appsettings ./appsettings
COPY ./Program ./Program
COPY ./SimpleQRGenerator ./SimpleQRGenerator

# Restauramos las dependencias y compilamos el proyecto
RUN dotnet restore ./simpleqrGenerator.sln
RUN dotnet build ./simpleqrGenerator.sln -c Release -o /app/build

# Cuando se ha completado la compilación, publicamos la aplicación
RUN dotnet publish ./simpleqrGenerator.sln -c Release -o /app/publish

# Utilizamos una imagen ligera de ASP.NET Core para ejecutar la aplicación
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos el resultado de la publicación desde la imagen de compilación
COPY --from=build-env /app/publish .

# Especificamos el comando de inicio para ejecutar la aplicación
ENTRYPOINT ["dotnet", "SimpleQRGenerator.dll"]
