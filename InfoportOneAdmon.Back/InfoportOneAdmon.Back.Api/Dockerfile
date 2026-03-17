# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# This stage is used to install curl in the container
USER root
RUN apt-get update && apt-get install -y curl
USER $APP_UID

USER root
RUN apt-get update && apt-get install -y \   
    libfontconfig1 \
    libfreetype6 \
    libharfbuzz0b \
    && rm -rf /var/lib/apt/lists/*
USER $APP_UID

###########################
##	  BUILDER
###########################

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release

ARG FEED_SOURCE
ARG FEED_USER
ARG FEED_ACCESSTOKEN

WORKDIR /src
COPY ["Directory.Build.props", "."]
COPY ["InfoportOneAdmon.Back.Api/InfoportOneAdmon.Back.Api.csproj", "InfoportOneAdmon.Back.Api/"]
COPY ["InfoportOneAdmon.Back.DataModel/InfoportOneAdmon.Back.DataModel.csproj", "InfoportOneAdmon.Back.DataModel/"]
COPY ["InfoportOneAdmon.Back.Data/InfoportOneAdmon.Back.Data.csproj", "InfoportOneAdmon.Back.Data/"]
COPY ["InfoportOneAdmon.Back.Entities/InfoportOneAdmon.Back.Entities.csproj", "InfoportOneAdmon.Back.Entities/"]
COPY ["InfoportOneAdmon.Back.DB/InfoportOneAdmon.Back.DB.csproj", "InfoportOneAdmon.Back.DB/"]
COPY ["InfoportOneAdmon.Back.Services/InfoportOneAdmon.Back.Services.csproj", "InfoportOneAdmon.Back.Services/"]

RUN dotnet new nugetconfig --force
RUN dotnet nuget add source "$FEED_SOURCE" -n IPVFeed -u "$FEED_USER" -p "$FEED_ACCESSTOKEN" --store-password-in-clear-text --valid-authentication-types basic --configfile nuget.config

COPY . .
RUN dotnet restore "./InfoportOneAdmon.Back.Api/InfoportOneAdmon.Back.Api.csproj"

WORKDIR "/src/InfoportOneAdmon.Back.Api"
RUN dotnet build "./InfoportOneAdmon.Back.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build --no-restore --verbosity normal

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./InfoportOneAdmon.Back.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

#RUN useradd aspnet
#RUN chown -R aspnet:aspnet /app
#USER aspnet
ARG APP_VERSION
ARG APP_BUILD_NUMBER
ARG CREATION_DATE
LABEL infoport.vendor="Infoport" \
	  infoport.version=$APP_VERSION \
	  infoport.revision=$APP_BUILD_NUMBER \
	  infoport.created=$CREATION_DATE

ENTRYPOINT ["dotnet", "InfoportOneAdmon.Back.Api.dll"]