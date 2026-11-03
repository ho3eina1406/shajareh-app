using Microsoft.EntityFrameworkCore;
using Shajareh.Api.Data;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("Shajareh")
    ?? Environment.GetEnvironmentVariable("SHajareh_DATABASE")
    ?? "Host=localhost;Port=5432;Database=shajareh;Username=shajareh;Password=change-me";

builder.Services.AddDbContext<ShajarehDbContext>(options =>
    options.UseNpgsql(connectionString));
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ShajarehDbContext>("postgresql");

builder.Services.AddOpenApi();
builder.Services.AddCors(options => options.AddPolicy("WebApp", policy =>
    policy.WithOrigins(builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [])
        .AllowAnyHeader()
        .AllowAnyMethod()));

var app = builder.Build();
app.UseHttpsRedirection();
app.UseCors("WebApp");

app.MapGet("/", () => Results.Ok(new
{
    application = "Shajareh API",
    status = "running",
    version = "0.1.0",
    note = "API foundation only; authentication and family endpoints are not enabled yet."
}));
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/ready");

if (app.Environment.IsDevelopment())
    app.MapOpenApi();

app.Run();
