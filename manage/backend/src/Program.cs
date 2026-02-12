using Microsoft.EntityFrameworkCore;
using NiceSpeak.Admin.Data;
using NiceSpeak.Admin.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure Services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database - 使用 SQLite (可改為 PostgreSQL/MySQL)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Data Source=nice_speak_admin.db";

builder.Services.AddDbContext<AdminDbContext>(options =>
    options.UseSqlite(connectionString));

// Services
builder.Services.AddScoped<RoleService>();
builder.Services.AddScoped<PermissionService>();
builder.Services.AddScoped<MenuService>();
builder.Services.AddScoped<UserService>();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure Pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// 確保資料庫建立
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AdminDbContext>();
    context.Database.EnsureCreated();
}

app.Run();
