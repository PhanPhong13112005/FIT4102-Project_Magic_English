using Microsoft.EntityFrameworkCore;
using MagicEnglishAPI.Data;
using MagicEnglishAPI.Services;
using Serilog;

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Starting Magic English API");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog();

    // Add DbContext
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    builder.Services.AddDbContext<MagicEnglishDbContext>(options =>
        options.UseSqlServer(connectionString));

    // Add services
    builder.Services.AddScoped<IOllamaService, OllamaService>();
    builder.Services.AddScoped<IVocabularyService, VocabularyService>();
    builder.Services.AddScoped<IGrammarService, GrammarService>();
    builder.Services.AddScoped<IStatisticsService, StatisticsService>();
    builder.Services.AddScoped<IUserService, UserService>();

    // Add HTTP Client Factory
    builder.Services.AddHttpClient();
    builder.Services.AddHttpClient<IOllamaService, OllamaService>();

    // Add Controllers
    builder.Services.AddControllers();

    // Add Swagger
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    // Add CORS
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowFlutterApp", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });

    var app = builder.Build();

    // Apply migrations automatically
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<MagicEnglishDbContext>();
        dbContext.Database.Migrate();
    }

    // Test database connection
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<MagicEnglishDbContext>();
        try
        {
            dbContext.Database.OpenConnection();
            dbContext.Database.CloseConnection();
            Log.Information("Database connection test successful.");
        }
        catch (Exception ex)
        {
            Log.Fatal(ex, "Database connection test failed.");
            throw;
        }
    }

    // Configure HTTP request pipeline
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseHttpsRedirection();
    app.UseCors("AllowFlutterApp");
    app.UseAuthorization();
    app.MapControllers();

    Log.Information("Magic English API started successfully");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
