FROM mcr.microsoft.com/dotnet/runtime:10.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["HireMatch.Worker/HireMatch.Worker.csproj", "HireMatch.Worker/"]
COPY ["HireMatch.Services/HireMatch.Services.csproj", "HireMatch.Services/"]
COPY ["HireMatch.Model/HireMatch.Model.csproj", "HireMatch.Model/"]
RUN dotnet restore "HireMatch.Worker/HireMatch.Worker.csproj"
COPY . .
WORKDIR "/src/HireMatch.Worker"
RUN dotnet build "HireMatch.Worker.csproj" -c Release -o /app/build
RUN dotnet publish "HireMatch.Worker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "HireMatch.Worker.dll"]
