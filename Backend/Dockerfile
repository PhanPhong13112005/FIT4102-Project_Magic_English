# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy project file
COPY ["Backend.csproj", "./"]

# Restore dependencies
RUN dotnet restore "Backend.csproj"

# Copy source code
COPY . .

# Build
RUN dotnet build "Backend.csproj" -c Release -o /app/build

# Publish stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

COPY --from=build /app/build .

# Copy appsettings
COPY appsettings.Docker.json ./appsettings.Production.json

# Create directory for SQLite database
RUN mkdir -p /app/data

# Expose port
EXPOSE 5000
EXPOSE 5001

# Set environment
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Entry point
ENTRYPOINT ["dotnet", "Backend.dll"]
