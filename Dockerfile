FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS base
WORKDIR /src
COPY *.sln .
COPY UMS2Test/*.csproj UMS2Test/
RUN dotnet restore UMS2Test/*.csproj
COPY UMS2/*.csproj UMS2/
RUN dotnet restore UMS2/*.csproj
COPY . .

#Testing
FROM base AS testing
WORKDIR /src/UMS2
RUN dotnet build
WORKDIR /src/UMS2Test
RUN dotnet test

#Publishing
FROM base AS publish
WORKDIR /src/UMS2
RUN dotnet publish -c Release -o /src/publish

#Get the runtime into a folder called app
FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS runtime
WORKDIR /app
COPY --from=publish /src/publish .
#ENTRYPOINT ["dotnet", "UMS2.dll"]
CMD ASPNETCORE_URLS=https://*:PORT dotnet UMS2.dll