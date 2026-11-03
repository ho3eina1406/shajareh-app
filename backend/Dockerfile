FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY Directory.Build.props ./
COPY src/Shajareh.Api/Shajareh.Api.csproj src/Shajareh.Api/
RUN dotnet restore src/Shajareh.Api/Shajareh.Api.csproj
COPY src/ src/
RUN dotnet publish src/Shajareh.Api/Shajareh.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Shajareh.Api.dll"]
