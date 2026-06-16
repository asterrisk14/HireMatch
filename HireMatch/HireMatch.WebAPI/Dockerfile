FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 5086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["HireMatch.WebAPI/HireMatch.WebAPI.csproj", "HireMatch.WebAPI/"]
COPY ["HireMatch.Services/HireMatch.Services.csproj", "HireMatch.Services/"]
COPY ["HireMatch.Model/HireMatch.Model.csproj", "HireMatch.Model/"]
RUN dotnet restore "HireMatch.WebAPI/HireMatch.WebAPI.csproj"
COPY . .
WORKDIR "/src/HireMatch.WebAPI"
RUN dotnet build "HireMatch.WebAPI.csproj" -c Release -o /app/build
RUN dotnet publish "HireMatch.WebAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "HireMatch.WebAPI.dll"]
