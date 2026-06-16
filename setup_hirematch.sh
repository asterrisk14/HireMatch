#!/usr/bin/env bash

set -e

SOLUTION_NAME="HireMatch"

echo "Kreiram HireMatch Solution..."
mkdir $SOLUTION_NAME
cd $SOLUTION_NAME

dotnet new sln -n $SOLUTION_NAME

echo "Kreiram slojeve arhitekture..."
dotnet new webapi -n HireMatch.WebAPI --use-controllers

dotnet new classlib -n HireMatch.Services

dotnet new classlib -n HireMatch.Model

echo "Povezujem projekte u solution..."
dotnet sln add HireMatch.WebAPI/HireMatch.WebAPI.csproj
dotnet sln add HireMatch.Services/HireMatch.Services.csproj
dotnet sln add HireMatch.Model/HireMatch.Model.csproj

echo "Postavljam reference..."
dotnet add HireMatch.WebAPI reference HireMatch.Services/HireMatch.Services.csproj
dotnet add HireMatch.Services reference HireMatch.Model/HireMatch.Model.csproj

echo "Instaliram potrebne pakete za bazu i dokumentaciju..."
dotnet add HireMatch.Services package Microsoft.EntityFrameworkCore.SqlServer
dotnet add HireMatch.WebAPI package Microsoft.EntityFrameworkCore.Design
dotnet add HireMatch.WebAPI package Scalar.AspNetCore

echo "Pravim HireMatch strukturu foldera..."
mkdir -p HireMatch.WebAPI/Controllers
mkdir -p HireMatch.WebAPI/Middlewares

mkdir -p HireMatch.Services/Database
mkdir -p HireMatch.Services/Interfaces
mkdir -p HireMatch.Services/Implementations

mkdir -p HireMatch.Model/Requests
mkdir -p HireMatch.Model/Responses
mkdir -p HireMatch.Model/SearchObjects

echo "HireMatch projekt je generisan!"